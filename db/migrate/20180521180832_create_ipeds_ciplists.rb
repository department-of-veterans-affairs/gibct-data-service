class CreateIpedsCiplists < ActiveRecord::Migration
  def change
    create_table :ipeds_ciplists do |t|
      t.string :cross, null: false, index: true

      t.string :cip_code
      t.integer :ctotalt
      t.timestamps null: false
    end
  end
end

