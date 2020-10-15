# frozen_string_literal: true

module ExcelHelper
  module Loader
    include Common::Loader

    # Returns an array of these objects for each sheet in options[:sheets] array
    # {
    #   header_warnings: [],
    #   results: [],
    # }
    #
    def load_from_excel(file, options = {})
      merged_options = merge_options(options)
      spreadsheet = Roo::Spreadsheet.open(file)
      loaded_sheets = []

      merged_options[:sheets].each_with_index do |type, index|
        sheet = spreadsheet.sheet(index)
        sheet_klass = type.constantize

        sheet_klass.transaction do
          delete_all

          begin
            processed_sheet = process_sheet(sheet_klass, sheet)
          rescue NoMethodError
            processed_sheet = custom_process(sheet_klass, sheet, index)
          end

          loaded_sheets << {
              results: load_records(processed_sheet[:results], merged_options),
              header_warnings: processed_sheet[:header_warnings],
          }
        end
      end

      loaded_sheets
    end

    private

    def process_sheet(sheet_klass, sheet)
      results = []
      header_warnings = validate_headers(sheet_klass, sheet.row(1))

      {header_warnings: header_warnings, results: results}
    end

    def validate_headers(sheet_klass, values)
      missing_headers = (sheet_klass::CSV_CONVERTER_INFO.keys - values)
                            .map{|h| "#{h} is a missing header"}
      extra_headers = (values - sheet_klass::CSV_CONVERTER_INFO.keys)
                          .map{|h| "#{h} is a extra header"}

      missing_headers + extra_headers
    end

    #
    # And here we enter the custom code to deal with issues that occurring from possible bad excel files
    # This uses Roo to get the sheet_file path and create a Nokogiri::XML:Document to be parsed
    #
    def custom_process(sheet_klass, sheet, index)
      results = []
      # Get Roo::*::Sheet object for us to convert to Nokogiri::XML::Document
      sheet_file = sheet.sheet_files[index]
      # Get Nokogiri::XML::Document
      doc = Roo::Utils.load_xml(sheet_file).remove_namespaces!

      rows = doc.xpath('/worksheet/sheetData/row').to_a
      header_values = rows.shift.children.to_a.map{|c| c.content.downcase}
      header_warnings = validate_headers(sheet_klass, header_values)

      rows.each do |row|
        result = {}
        values = row.children.to_a.map{|c| c.content}

        header_values.each_with_index do |header, h_index|
          info = sheet_klass::CSV_CONVERTER_INFO[header]
          result[info[:column]] = info[:converter].convert(values[h_index]) if info.present?
        end
        results << sheet_klass.new(result)
      end

      {header_warnings: header_warnings, results: results}
    end

    # Makes first_line value be 1 to ignore header in spreadsheet
    def merge_options(options)
      {first_line: 1}.reverse_merge(options).reverse_merge(sheets: [name])
    end
  end
end
