class DropDataCsvs < ActiveRecord::Migration[5.2]
  def change
    if table_exists?("data_csvs")
      drop_table :data_csvs
    end
  end
end
