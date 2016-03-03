class CreateRawFiles < ActiveRecord::Migration
  def change
    create_table :raw_files do |t|
    	t.belongs_to :raw_file_source, null: false

    	t.string :name, null: false
    	t.datetime :upload_date, null: false
    	t.boolean :is_valid, default: false

    	# STI
    	t.string :type, null: false

      t.timestamps null: false

      t.index :raw_file_source_id
      t.index :name
      t.index :upload_date
    end
  end
end
