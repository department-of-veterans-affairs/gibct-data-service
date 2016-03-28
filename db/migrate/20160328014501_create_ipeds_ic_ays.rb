class CreateIpedsIcAys < ActiveRecord::Migration
  def change
    create_table :ipeds_ic_ays do |t|
      t.string :cross, null: false
      t.string :chg2ay3
      t.string :chg3ay3
      t.string :chg4ay3

      t.timestamps null: false

      t.index :cross
    end
  end
end
