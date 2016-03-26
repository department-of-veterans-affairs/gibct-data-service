class CreateArfGibills < ActiveRecord::Migration
  def change
    create_table :arf_gibills do |t|
      t.string :facility_code, null: false
      t.string :institution, null: false
      t.string :gibill, null: false

      t.timestamps null: false

      t.index :facility_code, unique: true
      t.index :institution
    end
  end
end
