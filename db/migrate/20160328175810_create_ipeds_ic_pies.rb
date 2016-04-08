class CreateIpedsIcPies < ActiveRecord::Migration
  def change
    create_table :ipeds_ic_pies do |t|
      t.string :cross, null: false
      t.integer :chg1py3, default: nil

      t.integer :tuition_in_state, default: nil
      t.integer :tuition_out_of_state, default: nil
      t.integer :books, default: nil

      t.timestamps null: false

      t.index :cross
    end
  end
end
