class CreateIpedsIcs < ActiveRecord::Migration
  def change
    create_table :ipeds_ics do |t|
      t.string :cross, null: false
      t.string :vet2, null: false
      t.string :vet3, null: false
      t.string :vet4, null: false
      t.string :vet5, null: false
      t.string :calsys, null: false
      t.string :distnced, null: false

      t.timestamps null: false

      t.index :cross
    end
  end
end
