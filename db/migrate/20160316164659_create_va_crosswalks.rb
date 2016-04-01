class CreateVaCrosswalks < ActiveRecord::Migration
  def change
    create_table :va_crosswalks do |t|
      t.string :facility_code, null: false
      t.string :institution
      t.string :cross
      t.string :ope

      t.timestamps null: false
      
      t.index :facility_code, unique: true
      t.index :institution
      t.index :cross
      t.index :ope
    end
  end
end
