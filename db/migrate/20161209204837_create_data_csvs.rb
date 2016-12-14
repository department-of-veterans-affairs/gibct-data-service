class CreateDataCsvs < ActiveRecord::Migration
  def change
    create_table :data_csvs do |t|
      t.belongs_to :version
      
      t.timestamps null: false
    end
  end
end
