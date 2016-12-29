class CreateCrosswalks < ActiveRecord::Migration
  def change
    create_table :crosswalks do |t|
      t.string :facility_code, index: true, unique: true, null: false
      t.string :institution, index: true
      t.string :cross, index: true
      t.string :city
      t.string :state
      t.string :ope, index: true
      t.string :notes

      t.timestamps null: false
    end
  end
end
