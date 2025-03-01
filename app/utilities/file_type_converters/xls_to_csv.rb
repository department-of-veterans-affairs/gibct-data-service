# frozen_string_literal: true

# some older versions of Excel spreadsheets don't work well with Roo.
module FileTypeConverters
  class XlsToCsv
    attr_accessor :xls_file_name, :csv_file_name

    def initialize(xls_file_name, csv_file_name)
      @xls_file_name = xls_file_name
      @csv_file_name = csv_file_name
    end

    def convert_xls_to_csv
      book = Spreadsheet.open(@xls_file_name)
      sheet = book.worksheet(0)

      CSV.open(@csv_file_name, 'wb') do |csv|
        sheet.each do |row|
          formatted_row = row.to_a.map do |cell|
            cell.is_a?(Float) ? format('%.0f', cell) : cell.to_s.strip
          end
          csv << formatted_row
        end
      end
      @csv_file_name
    end
  end
end
