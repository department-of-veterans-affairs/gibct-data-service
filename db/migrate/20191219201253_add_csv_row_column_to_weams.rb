class AddCsvRowColumnToWeams < ActiveRecord::Migration[5.2]
  def change
    add_column :weams, :csv_row, :integer
  end
end
