class CreateSec702s < ActiveRecord::Migration
  def change
    create_table :sec702s do |t|
      t.string :state, null: false
      t.boolean :sec_702, default: nil

      t.timestamps null: false

      t.index :state, unique: true
    end
  end
end
