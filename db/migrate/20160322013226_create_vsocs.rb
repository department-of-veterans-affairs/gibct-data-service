class CreateVsocs < ActiveRecord::Migration
  def change
    create_table :vsocs do |t|
      t.string :facility_code, null: false
      t.string :institution, null: false
      t.string :vetsuccess_name
      t.string :vetsuccess_email

      t.timestamps null: false

      t.index :facility_code, unique: true
      t.index :institution
    end
  end
end
