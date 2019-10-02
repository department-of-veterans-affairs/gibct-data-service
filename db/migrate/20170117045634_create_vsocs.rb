class CreateVsocs < ActiveRecord::Migration[4.2]
  def change
    create_table :vsocs do |t|
      # Used in the building of DataCsv
      t.string :facility_code, null: false
      t.string :vetsuccess_name
      t.string :vetsuccess_email

      # Not used in building DataCsv, but used in exporting source csv
      t.string :institution
      t.timestamps null: false

      t.index :facility_code, unique: true
    end
  end
end
