class CreateSec702s < ActiveRecord::Migration
  def change
    create_table :sec702s do |t|
      t.string :state, null: false
      t.string :sec_702, null: false

      t.timestamps null: false

      t.index :state, unique: true
    end
  end
end
