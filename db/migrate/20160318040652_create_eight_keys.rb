class CreateEightKeys < ActiveRecord::Migration
  def change
    create_table :eight_keys do |t|
      t.string :institution
      t.string :cross
      t.string :ope
      t.string :ope6

      t.timestamps null: false
      t.index :institution
      t.index :cross
      t.index :ope
      t.index :ope6
    end
  end
end
