class CreateRawCsvs < ActiveRecord::Migration
  def change
    create_table :raw_csvs do |t|
      t.string :csv_type, null: false
      t.binary :storage
      t.string :comment

      t.timestamps null: false

      t.index :csv_type, unique: :true
    end
  end
end
