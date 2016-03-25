class CreateMous < ActiveRecord::Migration
  def change
    create_table :mous do |t|
      t.string :ope, null: false
      t.string :institution, null: false
      t.string :city
      t.string :state
      t.string :status

      t.timestamps null: false

      t.index :ope 
      t.index :institution
    end
  end
end
