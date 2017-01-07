class CreateCrosswalks < ActiveRecord::Migration
  def change
    create_table :crosswalks do |t|
      t.string :facility_code, null: false
      t.string :institution
      t.string :cross
      t.string :city
      t.string :state
      t.string :ope
      t.string :notes

      t.timestamps null: false
      t.index :facility_code, unique: true
      t.index :institution
      t.index :cross
      t.index :ope
    end
  end
end
