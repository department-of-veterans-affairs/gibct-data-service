class CreateRawFileSources < ActiveRecord::Migration
  def change
    create_table :raw_file_sources do |t|
   		t.string :name, null: false
   		t.integer :build_order, null: false

      t.timestamps null: false

      t.index :name, unique: true
    end
  end
end
