# frozen_string_literal: true

module FileTypeConverters
  class XlsxToCsv
    attr_accessor :xls_file_name, :csv_file_name

    def initialize(xls_file_name, csv_file_name)
      @xls_file_name = xls_file_name
      @csv_file_name = csv_file_name
    end

    def convert_xlsx_to_csv
      spreadsheet = Roo::Spreadsheet.open(@xls_file_name)
      sheet = spreadsheet.sheet(0)

      CSV.open(@csv_file_name, 'wb') do |csv|
        sheet.each_row_streaming do |row|
          formatted_row = row.map do |cell|
            value = cell&.value
            value.is_a?(Float) ? format('%.0f', value) : value.to_s.strip
          end
          csv << formatted_row
        end
      end

      @csv_file_name
    end
  end
end
