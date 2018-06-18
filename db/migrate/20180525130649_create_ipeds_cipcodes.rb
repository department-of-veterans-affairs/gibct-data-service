class CreateIpedsCipcodes < ActiveRecord::Migration
  def change
    create_table :ipeds_cip_codes do |t|
      t.string :cross, null: false, index: true
      t.string :cipcode, index: true
      t.integer :ctotalt, index: true

      t.timestamps null: false
    end
  end
end

