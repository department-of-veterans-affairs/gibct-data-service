class CreateMous < ActiveRecord::Migration
  def change
    create_table :mous do |t|
      t.string :ope, null: false
      t.string :ope6, null: false
      t.string :institution
      t.string :status
      t.boolean :dodmou

      t.timestamps null: false

      t.index :ope 
      t.index :institution
    end
  end
end
