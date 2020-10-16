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
    #
    # rubocop:disable Metrics/MethodLength
    def load_with_roo(file, options = {})
      merged_options = merge_options(options)
      ext = File.extname(file)
      ext = '.csv' if ext == '.txt'
      spreadsheet_options = {extension: ext, csv_options: csv_options(file, options)}

      # This is the generic way to open a file Roo will return the correct class based on extension
      spreadsheet = Roo::Spreadsheet.open(file, spreadsheet_options)
      loaded_sheets = []

      merged_options[:sheets].each_with_index do |type, index|
        sheet = spreadsheet.sheet(index)
        sheet_klass = type.constantize

        sheet_klass.transaction do
          delete_all

          if options[:parse_as_xml]
            processed_sheet = process_as_xml(sheet_klass, sheet, index)
          else
            processed_sheet = process_sheet(sheet_klass, sheet)
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

    def process_sheet(sheet_klass, sheet)
      results = []
      headers = sheet.row(1)

      fields = {}

      # create array of csv column headers
      # if there is an extra column in file use it's value
      headers.each do |header|
        info = sheet_klass::CSV_CONVERTER_INFO[header.downcase]
        column = info.blank? ? header.to_sym : info[:column]
        fields[column] = header
      end

      binding.pry
      sheet.each(fields) do |hash|
        result = {}

        # call converters for each field and ignore extra columns from the file
        hash.each_pair do |key, value|
          info = sheet_klass::CSV_CONVERTER_INFO[fields[key].downcase]
          result[key] = info[:converter].convert(value) if info.present?
        end

        results << sheet_klass.new(result)
      end

      {
        header_warnings: header_warnings(sheet_klass, headers.map(&:downcase)),
        results: results
      }
    end

    def header_warnings(sheet_klass, values)
      missing_headers = (sheet_klass::CSV_CONVERTER_INFO.keys - values)
                        .map { |h| "#{h} is a missing header" }
      extra_headers = (values - sheet_klass::CSV_CONVERTER_INFO.keys)
                      .map { |h| "#{h} is a extra header" }

      missing_headers + extra_headers
    end

    # Set default options if not provided
    # - :first_line  Since row indexes start at 0 and spreadsheets on line 1,
    #               add 1 for the difference in indexes and 1 for the header row itself.
    # - :sheets  Default sheets array is the class that called load_with_roo
    # - :parse_as_xml  defaults to false
    def merge_options(options)
      options.reverse_merge(sheets: [name], parse_as_xml: false, first_line: 2)
    end

    def csv_options(file, options)
      csv_options = {
          col_sep: csv_col_sep(file, options),
          # skip_lines: options[:skip_lines],
          # headers: true,
      }
      # csv_options[:header_converters] = lambda { |h| h.gsub(options[:header_converter_regex], '')} if options[:header_converter_regex]
      csv_options
    end

    def csv_col_sep(file, options)
      csv = File.open(file, encoding: 'ISO-8859-1')
      options[:skip_lines].to_i.times { csv.readline }

      first_line = csv.readline
      col_sep = Settings.csv_upload.column_separators
                         .find { |column_separator| first_line.include?(column_separator) }
      valid_col_seps = valid_col_seps[:value].map { |cs| "\"#{cs}\"" }.join(' and ')
      error_message = "Unable to determine column separators, valid separators equal #{valid_col_seps}"
      raise(StandardError, error_message) if col_sep.blank?

      col_sep
    end

    def valid_col_seps
      valid_col_seps = Settings.csv_upload.column_separators.each(&:to_s)
      { value: valid_col_seps, message: 'Valid column separators are:' }
    end

    # This is called if options[:parse_as_xml] is true
    #
    # This is the custom code to deal with issues that occurring from malformed excel files
    # This uses Roo to get the sheet_file path and create a Nokogiri::XML:Document to be parsed
    #
    def process_as_xml(sheet_klass, sheet, index)
      results = []
      # Get Roo::*::Sheet object for us to convert to Nokogiri::XML::Document
      sheet_file = sheet.sheet_files[index]
      # Get Nokogiri::XML::Document
      doc = Roo::Utils.load_xml(sheet_file).remove_namespaces!

      rows = doc.xpath('/worksheet/sheetData/row').to_a
      header_values = rows.shift.children.to_a.map { |c| c.content.downcase }

      rows.each do |row|
        result = {}
        values = row.children.to_a.map(&:content)

        # call converters for each field and ignore extra columns from the file
        header_values.each_with_index do |header, h_index|
          info = sheet_klass::CSV_CONVERTER_INFO[header]
          result[info[:column]] = info[:converter].convert(values[h_index]) if info.present?
        end

        results << sheet_klass.new(result)
      end

      { header_warnings: header_warnings(sheet_klass, header_values), results: results }
    end
  end
end
