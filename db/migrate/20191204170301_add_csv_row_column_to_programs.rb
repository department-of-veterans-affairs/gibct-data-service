class AddCsvRowColumnToPrograms < ActiveRecord::Migration[5.2]
  def change
    add_column :programs, :csv_row, :integer
  end
end
