class CreateCsvFiles < ActiveRecord::Migration
  def change
    create_table :csv_files do |t|
      t.string :csv_type, index: true, null: false
      t.string :name, null: false
      t.string :description
      t.string :user, index: true, null: false
      t.integer :skip_lines_before_header, null: false, default: 3
      t.integer :skip_lines_after_header, null: false, default: 0
      t.string :delimiter, null: false, default: ','
      t.string :result, default: 'not uploaded'

      t.timestamps null: false
    end
  end
end
