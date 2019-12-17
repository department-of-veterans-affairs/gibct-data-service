class DropCsvStorages < ActiveRecord::Migration[5.2]
  def change
    if table_exists?("csv_storages")
      drop_table :csv_storages
    end
  end
end
