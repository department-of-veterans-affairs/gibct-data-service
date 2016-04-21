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

      t.boolean :credit_for_mil_training, default: nil
      t.boolean :vet_poc, default: nil
      t.boolean :student_vet_grp_ipeds, default: nil
      t.boolean :soc_member, default: nil
      t.string :calendar, default: nil
      t.boolean :online_all, default: nil

      t.timestamps null: false

      t.index :cross
    end
  end
end
