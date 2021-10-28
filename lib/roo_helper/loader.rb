# frozen_string_literal: true

module RooHelper
  module Loader
    include Common::Loader

    # Returns an array of these objects for each sheet_option object in options[:sheets] array
    # {
    #   header_warnings: [],
    #   results: [],
    #   klass: ImportableRecord,
    # }
    #
    # Sheet Option hashes
    # - :sheets An array of hashes whose order determines which sheet in a spreadsheet
    #           maps to which class, creates a transaction for each class
    #
    #   - :klass The ImportableRecord class
    #   - :skip_lines Number of lines to skip before Header row, used for warning messages and finding headers.
    #                 Set this to -1 for files without header rows.
    #   - :first_line This is used for warning messages, default value is 2
    #   - :clean_rows Enable/Disable regex /[[:cntrl:]]|^[\p{Space}]+|[\p{Space}]+$/
    #                 from being applied when pulling rows from file
    #   - :multiple_files  When set to true disables the sheet_klass.delete_all for the file.
    #   - :no_headers When file does not contain headers
    #
    # File Options
    # - :liberal_parsing  Used when file is either .txt or .csv
    #                     When setting a true value, CSV will attempt to parse input not
    #                     conformant with RFC 4180, such as double quotes in unquoted fields.
    #
    def load_with_roo(file, options = {})
      file_options = merge_options(options)
      ext = File.extname(file)
      ext = '.csv' if ext == '.txt'

      spreadsheet_options = { extension: ext,
                              csv_options: ext == '.csv' ? csv_options(file, file_options) : nil }

      # This is the generic way to open a file Roo will return the correct class based on extension
      spreadsheet = Roo::Spreadsheet.open(file, spreadsheet_options)
      loaded_sheets = []

      file_options[:sheets].each_with_index do |sheet_options, index|
        sheet = spreadsheet.sheet(index)
        sheet_klass = sheet_options[:klass]

        sheet_klass.transaction do
          sheet_klass.delete_all unless sheet_options[:multiple_files]

          processed_sheet = if %w[.xls .xlsx].include?(ext) && parse_as_xml?(sheet, index)
                              process_as_xml(sheet_klass, sheet, index, sheet_options)
                            else
                              process_sheet(sheet_klass, sheet, sheet_options, file_options)
                            end

          loaded_sheets << {
            results: sheet_klass.load_records(processed_sheet[:results], sheet_options),
            header_warnings: processed_sheet[:header_warnings],
            klass: sheet_klass
          }
        end
      end

      loaded_sheets
    end

    # Load multiple files at a time
    #
    # Assume all files are of the same type
    def load_multiple_files(files, klass)
      options = Common::Shared.file_type_defaults(klass.name)
      file_options = { liberal_parsing: options[:liberal_parsing],
                       sheets: [{ klass: klass,
                                  skip_lines: options[:skip_lines],
                                  multiple_files: options[:multiple_files],
                                  no_headers: options[:no_headers] }] }

      # The option disables deleting when each file is loaded and instead allows for a single deletion before loading
      klass.delete_all if options[:multiple_files]

      files.map do |file|
        CensusLatLong.load_with_roo(file, file_options)
      end
    end

    private

    # Check for the presence of the missing attribute which requires custom processing if not present
    def parse_as_xml?(sheet, index)
      # Get Roo::*::Sheet object for us to convert to Nokogiri::XML::Document
      sheet_file = sheet.sheet_files[index]
      # Get Nokogiri::XML::Document
      doc = Roo::Utils.load_xml(sheet_file).remove_namespaces!

      xml_rows = doc.xpath('/worksheet/sheetData/row')
      # check for the r attribute of one of columns in a row
      # the r attribute will have a value of A1 or N37 which is used in the Roo gem but causes
      # errors if not present
      xml_rows.to_a[0].children[0][:r].blank?
    end

    # Get rows from the sheet
    def sheet_rows(sheet, sheet_options, file_headers, headers_mapping)
      # do not need to account for sheet_options[:skip_lines] here because of passing in the headers_mapping
      if sheet_options[:no_headers]
        # iterate through each row and zip the headers and values together to make Hashes
        sheet.each.map { |row| Hash[file_headers.map(&:to_sym).zip(row)] }.to_a
      elsif sheet_options[:clean_rows]
        sheet.parse(headers_mapping.merge(clean: true))
      else
        sheet.parse(headers_mapping)
      end
    end

    # By providing a block the row object can be modified or set as needed
    # If a block is not provided and row is an array zips the headers and row together to create a Hash
    #
    # Provides location for common operations on a row object
    def parse_rows(sheet_klass, rows, sheet_options)
      results = []
      rows.each_with_index do |row, r_index|
        result = if block_given?
                   yield(row)
                 else
                   row
                 end

        skip_lines = if sheet_options[:no_headers]
                       -1
                     else
                       sheet_options[:skip_lines]
                     end

        csv_row = r_index + sheet_options[:first_line] + skip_lines
        result[:csv_row] = csv_row if sheet_klass.column_names.include?('csv_row')

        results << sheet_klass.new(result)
      end
      results
    end

    # Main way to convert data in a sheet to ImportableRecords
    #
    # Uses file_options[:liberal_parsing] to strip quotes out
    def process_sheet(sheet_klass, sheet, sheet_options, file_options)
      file_headers = if sheet_options[:no_headers]
                       sheet_klass::CSV_CONVERTER_INFO.keys
                     else
                       sheet.row(1 + sheet_options[:skip_lines]).compact
                     end
      headers_mapping = {}

      # create array of csv column headers
      # if there is an extra column in file use it's value for headers_mapping
      file_headers.each do |header|
        file_header = header.strip
        key = file_options[:liberal_parsing] ? file_header.gsub('"', '').strip : file_header
        info = converter_info(sheet_klass, key)
        column = info.blank? ? file_header.downcase.to_sym : info[:column]
        headers_mapping[column] = file_header
      end

      rows = sheet_rows(sheet, sheet_options, file_headers, headers_mapping)

      results = parse_rows(sheet_klass, rows, sheet_options) do |row|
        result = {}

        # call converter on each column
        row.each_pair do |key, value|
          file_header = file_options[:liberal_parsing] ? headers_mapping[key].gsub('"', '').strip : headers_mapping[key]
          info = converter_info(sheet_klass, file_header)
          if info.present?
            converter = info[:converter] || BaseConverter
            result[key] = converter.convert(value)
          end
        end

        result
      end

      header_warning_messages = if sheet_options[:no_headers]
                                  []
                                else
                                  header_warnings(sheet_klass, file_headers.map { |h| h.strip.downcase })
                                end

      { header_warnings: header_warning_messages, results: results }
    end

    def converter_info(sheet_klass, header)
      sheet_klass::CSV_CONVERTER_INFO[Common::Shared.convert_csv_header(header).downcase]
    end

    # Determine missing and extra headers
    #
    # Returns array of warning messages
    def header_warnings(sheet_klass, values)
      headers = values.dup.map { |h| Common::Shared.convert_csv_header(h) }
      missing_headers = (sheet_klass::CSV_CONVERTER_INFO.keys - headers)
                        .map { |h| "#{Common::Shared.display_csv_header(h).capitalize} is a missing header" }
      extra_headers = (headers - sheet_klass::CSV_CONVERTER_INFO.keys)
                      .map { |h| "#{Common::Shared.display_csv_header(h).capitalize} is an extra header" }

      missing_headers + extra_headers
    end

    # Set default options if not provided
    # - :sheets  Default sheets array uses the class that called load_with_roo
    #   - :first_line Since row indexes start at 0 and spreadsheets on line 1,
    #                 add 1 for the difference in indexes and 1 for the header row itself.
    #   - :skip_lines defaults to 0
    def merge_options(file_options)
      file_options[:sheets] = if file_options[:sheets].present?
                                file_options[:sheets]
                                  .map { |sheet| sheet.reverse_merge(skip_lines: 0, first_line: 2) }
                              else
                                [{ klass: klass, skip_lines: 0, first_line: 2, clean_rows: true,
                                   multiple_files: false }]
                              end

      file_options
    end

    # Set CSV options
    # See https://apidock.com/ruby/v2_5_5/CSV/new/class for more options
    # Forces encoding to be utf-8
    def csv_options(file, file_options)
      csv_options = {
        col_sep: csv_col_sep(file, file_options),
        encoding: 'ISO-8859-1'
      }
      csv_options[:liberal_parsing] = file_options[:liberal_parsing]
      csv_options
    end

    # Attempt to determine for a CSV if the col_sep is a ',' or '|'
    def csv_col_sep(file, file_options)
      csv = File.open(file, encoding: 'ISO-8859-1')
      # CSV files only have 1 sheet so get skip_lines from first sheets element
      file_options[:sheets][0][:skip_lines].to_i.times { csv.readline }

      first_line = csv.readline
      col_sep = Settings.csv_upload.column_separators
                        .find { |column_separator| first_line.include?(column_separator) }
      valid_col_seps_msg = RooHelper.valid_col_seps[:value].map { |cs| "\"#{cs}\"" }.join(' and ')
      error_message = "Unable to determine column separators, valid separators equal #{valid_col_seps_msg}"
      raise(StandardError, error_message) if col_sep.blank?

      col_sep
    end

    # This is called if %w[.xls .xlsx].include?(ext) && parse_as_xml?(sheet, index) is true
    #
    # This is the custom code to deal with issues that occur from malformed excel files
    # ex: No "r" attribute on the cell elements, this indicates "A1" or "D32"
    #
    # This uses Roo to get the sheet_file path and create a Nokogiri::XML:Document to be parsed
    #
    def process_as_xml(sheet_klass, sheet, index, sheet_options)
      # Get Roo::*::Sheet object for us to convert to Nokogiri::XML::Document
      sheet_file = sheet.sheet_files[index]
      # Get Nokogiri::XML::Document
      doc = Roo::Utils.load_xml(sheet_file).remove_namespaces!

      # path to the rows within the sheet
      rows = doc.xpath('/worksheet/sheetData/row').to_a.drop(sheet_options[:skip_lines])
      headers = rows.shift.children.to_a.map { |c| c.content.strip.downcase }

      results = parse_rows(sheet_klass, rows, sheet_options) do |row|
        result = {}
        values = row.children.to_a.map(&:content)

        # call converters for each field and ignore extra columns from the file
        headers.each_with_index do |header, h_index|
          info = converter_info(sheet_klass, header)
          if info.present?
            converter = info[:converter] || BaseConverter
            result[info[:column]] = converter.convert(values[h_index])
          end
        end
        result
      end

      { header_warnings: header_warnings(sheet_klass, headers), results: results }
    end
  end
end
