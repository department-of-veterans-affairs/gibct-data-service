class CreateIpedsHds < ActiveRecord::Migration
  def change
    create_table :ipeds_hds do |t|
      t.string :cross, null: false
      t.string :vet_tuition_policy_url

      t.timestamps null: false

      t.index :cross
    end
  end
end
