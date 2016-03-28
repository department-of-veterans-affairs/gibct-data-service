class CreateIpedsIcPies < ActiveRecord::Migration
  def change
    create_table :ipeds_ic_pies do |t|
      t.string :cross, null: false
      t.string :chg1py3
      t.string :chg5py3

      t.timestamps null: false

      t.index :cross
    end
  end
end
