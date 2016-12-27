class CreateDataCsvs < ActiveRecord::Migration
  def change
    create_table :data_csvs do |t|
      t.integer :version, index: true, null:false
      
      t.timestamps null: false
    end
  end
end
