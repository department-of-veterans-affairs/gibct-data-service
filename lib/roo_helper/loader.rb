# frozen_string_literal: true

module RooHelper
  module Loader
    include Common::Loader

    # Returns an array of these objects for each sheet in options[:sheets] array
    # {
    #   header_warnings: [],
    #   results: [],
    # }
    #
    # Options
    # - :sheets An array of classes whose order determines which sheet in a spreadsheet
    #           maps to which class, creates a transaction for each class
    # - :parse_as_xml If the uploaded xlsx or xls file fails to process normally pass in this option to
    #                 process as Nokogiri::XML object instead
    # - :skip_lines Number of lines to skip before Header row, used for warning messages and finding headers
    # - :first_line This is used for warning messages, default value is 2
    # - :liberal_parsing used when file is either .txt or .csv
    #
    # rubocop:disable Metrics/MethodLength
    def load_with_roo(file, options = {})
      merged_options = merge_options(options)
      ext = File.extname(file)
      ext = '.csv' if ext == '.txt'
      spreadsheet_options = { extension: ext, csv_options: csv_options(file, options) }

      # This is the generic way to open a file Roo will return the correct class based on extension
      spreadsheet = Roo::Spreadsheet.open(file, spreadsheet_options)
      loaded_sheets = []

      merged_options[:sheets].each_with_index do |sheet_klass, index|
        sheet = spreadsheet.sheet(index)

        sheet_klass.transaction do
          delete_all

          processed_sheet = if options[:parse_as_xml]
                              process_as_xml(sheet_klass, sheet, index, merged_options)
                            else
                              process_sheet(sheet_klass, sheet, merged_options)
                            end

          loaded_sheets << {
            results: load_records(processed_sheet[:results], merged_options),
            header_warnings: processed_sheet[:header_warnings]
          }
        end
      end

      loaded_sheets
    end
    # rubocop:enable Metrics/MethodLength

    private

    # By providing a block the row object can be modified or set as needed
    # If a block is not provided and row is an array zips the headers and row together to create a Hash
    #
    # Provides location for common operations on a row object
    def parse_rows(sheet_klass, headers, rows, options)
      results = []
      rows.each_with_index do |row, r_index|
        result = if block_given?
                   yield(row)
                 else
                   row.is_a? Hash ? row : Hash[headers.zip(row)]
                 end

        csv_row = r_index + options[:first_line] + skip_lines(options)
        result[:csv_row] = csv_row if sheet_klass.column_names.include?('csv_row')

        results << sheet_klass.new(result)
      end
      results
    end

    def process_sheet(sheet_klass, sheet, options)
      file_headers = sheet.row(1 + skip_lines(options))
      fields = {}

      # create array of csv column headers
      # if there is an extra column in file use it's value
      file_headers.each do |header|
        file_header = header.strip
        key = options[:liberal_parsing] ? file_header.gsub('"', '').strip : file_header
        info = converter_info(sheet_klass, key)
        column = info.blank? ? file_header.downcase.to_sym : info[:column]
        fields[column] = file_header
      end

      # do not need to account for options[:skip_lines] here because of passing in the headers hash
      rows = sheet.parse(fields.merge(clean: true))

      results = parse_rows(sheet_klass, file_headers, rows, options) do |row|
        result = {}
        row.each_pair do |key, value|
          file_header = options[:liberal_parsing] ? fields[key].gsub('"', '').strip : fields[key]
          info = converter_info(sheet_klass, file_header)
          result[key] = info[:converter].convert(value) if info.present?
        end
        result
      end

      { header_warnings: header_warnings(sheet_klass, file_headers.map { |h| h.strip.downcase }), results: results }
    end

    def converter_info(sheet_klass, header)
      sheet_klass::CSV_CONVERTER_INFO[header.downcase]
    end

    def header_warnings(sheet_klass, values)
      missing_headers = (sheet_klass::CSV_CONVERTER_INFO.keys - values)
                        .map { |h| "#{h} is a missing header" }
      extra_headers = (values - sheet_klass::CSV_CONVERTER_INFO.keys)
                      .map { |h| "#{h} is a extra header" }

      missing_headers + extra_headers
    end

    # Set default options if not provided
    # - :first_line Since row indexes start at 0 and spreadsheets on line 1,
    #               add 1 for the difference in indexes and 1 for the header row itself.
    # - :sheets  Default sheets array is the class that called load_with_roo
    # - :parse_as_xml  defaults to false
    # - :liberal_parsing When setting a true value, CSV will attempt to parse input not
    #                    conformant with RFC 4180, such as double quotes in unquoted fields.
    def merge_options(options)
      options.reverse_merge(sheets: [klass], parse_as_xml: false, first_line: 2)
    end

    def csv_options(file, options)
      csv_options = {
        col_sep: csv_col_sep(file, options)
      }
      csv_options[:liberal_parsing] = options[:liberal_parsing]
      csv_options
    end

    def csv_col_sep(file, options)
      csv = File.open(file, encoding: 'ISO-8859-1')
      options[:skip_lines].to_i.times { csv.readline }

      first_line = csv.readline
      col_sep = Settings.csv_upload.column_separators
                        .find { |column_separator| first_line.include?(column_separator) }
      valid_col_seps_msg = RooHelper.valid_col_seps[:value].map { |cs| "\"#{cs}\"" }.join(' and ')
      error_message = "Unable to determine column separators, valid separators equal #{valid_col_seps_msg}"
      raise(StandardError, error_message) if col_sep.blank?

      col_sep
    end

    # This is called if options[:parse_as_xml] is true
    #
    # This is the custom code to deal with issues that occurring from malformed excel files
    # This uses Roo to get the sheet_file path and create a Nokogiri::XML:Document to be parsed
    #
    def process_as_xml(sheet_klass, sheet, index, options)
      # Get Roo::*::Sheet object for us to convert to Nokogiri::XML::Document
      sheet_file = sheet.sheet_files[index]
      # Get Nokogiri::XML::Document
      doc = Roo::Utils.load_xml(sheet_file).remove_namespaces!

      rows = doc.xpath('/worksheet/sheetData/row').to_a.drop(skip_lines(options))
      headers = rows.shift.children.to_a.map { |c| c.content.strip.downcase }

      results = parse_rows(sheet_klass, headers, rows, options) do |row|
        result = {}
        values = row.children.to_a.map(&:content)

        # call converters for each field and ignore extra columns from the file
        headers.each_with_index do |header, h_index|
          info = converter_info(sheet_klass, header)
          result[info[:column]] = info[:converter].convert(values[h_index]) if info.present?
        end
        result
      end

      { header_warnings: header_warnings(sheet_klass, headers), results: results }
    end

    def skip_lines(options)
      options[:skip_lines] || 0
    end
  end
end
