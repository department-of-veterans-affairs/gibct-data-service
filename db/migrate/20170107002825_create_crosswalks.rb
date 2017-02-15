class CreateCrosswalks < ActiveRecord::Migration
  def change
    create_table :crosswalks do |t|
      # Used in the building of DataCsv
      t.string :facility_code, null: false
      t.string :cross
      t.string :ope
      t.string :ope6

      # Not used in building DataCsv, but used in exporting source csv
      t.string :city
      t.string :state
      t.string :institution
      t.string :notes
      t.timestamps null: false

      t.index :facility_code, unique: true
      t.index :institution
      t.index :cross, unique: true
      t.index :ope, unique: true
      t.index :ope6
    end
  end
end
