# frozen_string_literal: true
class CreateEightKeys < ActiveRecord::Migration
  def change
    create_table :eight_keys do |t|
      # Used in the building of DataCsv
      t.string :cross

      t.string :institution
      t.string :city
      t.string :state
      t.string :ope
      t.string :ope6
      t.string :notes
      t.timestamps null: false

      t.index :institution
      t.index :cross, unique: true
      t.index :ope, unique: true
      t.index :ope6
    end
  end
end
