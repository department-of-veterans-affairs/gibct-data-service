class CreateCsvFiles < ActiveRecord::Migration
  def change
  	create_table :csv_files do |t|
  		t.belongs_to :raw_file_source, null: false
  		t.binary :data

  		t.timestamps null: false

  		t.index :raw_file_source_id, unique: true
  	end
  end
end
