class CreateP911Yrs < ActiveRecord::Migration
  def change
    create_table :p911_yrs do |t|
      t.string :facility_code, null: false
      t.string :institution
      t.float :p911_yellow_ribbon, null: false
      t.integer :p911_yr_recipients, null: false

      t.timestamps null: false

      t.index :facility_code, unique: true
      t.index :institution
    end
  end
end
