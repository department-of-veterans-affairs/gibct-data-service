class DropCsvFiles < ActiveRecord::Migration[5.2]
  def change
    if table_exists?("csv_files")
      drop_table :csv_files
    end
  end
end
