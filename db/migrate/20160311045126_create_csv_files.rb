class CreateCsvFiles < ActiveRecord::Migration
  def change
    create_table :csv_files do |t|
    	t.string :name, null: false
    	
    	t.datetime :upload_date, null: false
      t.string :delimiter, null: false, default: ","

    	# STI
    	t.string :type, null: false

      t.timestamps null: false

      t.index :name
      t.index :upload_date
    end
  end
end
