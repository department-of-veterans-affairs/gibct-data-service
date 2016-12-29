class CreateCsvFiles < ActiveRecord::Migration
  def change
    create_table :csv_files do |t|
      t.belongs_to :user, null: false

      t.string :csv_type, null: false
      t.string :name, null: false
      t.string :description
      t.integer :skip_lines_before_header, null: false, default: 3
      t.integer :skip_lines_after_header, null: false, default: 0
      t.string :delimiter, null: false, default: ','
      t.string :result, default: 'not uploaded'

      t.timestamps null: false
      t.index :user_id
      t.index :csv_type
    end
  end
end
