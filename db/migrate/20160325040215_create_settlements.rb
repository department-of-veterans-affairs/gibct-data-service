class CreateSettlements < ActiveRecord::Migration
  def change
    create_table :settlements do |t|
      t.string :cross, null: false
      t.string :institution
      t.string :settlement_description, null: false

      t.timestamps null: false

      t.index :cross 
      t.index :institution
    end
  end
end
