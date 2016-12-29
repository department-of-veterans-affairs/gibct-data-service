class CreateDataCsvs < ActiveRecord::Migration
  def change
    create_table :data_csvs do |t|
      t.integer :version, null: false

      t.timestamps null: false
      t.index :version
    end
  end
end
