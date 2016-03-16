class CreateCsvStorages < ActiveRecord::Migration
  def change
    create_table :csv_storages do |t|
      t.binary :data_store
      t.string :csv_file_type, null: false

      t.timestamps null: false

      t.index :csv_file_type, unique: true
    end
  end
end
