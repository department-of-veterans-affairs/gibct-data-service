class CreateIpedsCiplists < ActiveRecord::Migration
  def change
    create_table :ipeds_ciplists do |t|
      t.string :cross, null: false

      t.string :cip_code
      t.integer :ctotalt
      t.timestamps null: false

      t.index :cross
    end
  end
end

