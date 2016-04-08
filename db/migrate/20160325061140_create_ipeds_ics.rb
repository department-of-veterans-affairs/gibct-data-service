class CreateIpedsIcs < ActiveRecord::Migration
  def change
    create_table :ipeds_ics do |t|
      t.string :cross, null: false
      t.integer :vet2, null: false
      t.integer :vet3, null: false
      t.integer :vet4, null: false
      t.integer :vet5, null: false
      t.integer :calsys, null: false
      t.integer :distnced, null: false

      t.string :credit_for_mil_training, default: nil
      t.string :vet_poc, default: nil
      t.string :student_vet_grp_ipeds, default: nil
      t.string :soc_member, default: nil
      t.string :calendar, default: nil
      t.string :online_all, default: nil

      t.timestamps null: false

      t.index :cross
    end
  end
end
