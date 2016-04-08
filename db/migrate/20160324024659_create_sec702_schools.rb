class CreateSec702Schools < ActiveRecord::Migration
  def change
    create_table :sec702_schools do |t|
      t.string :facility_code, null: false
      t.boolean :sec_702, default: nil

      t.timestamps null: false

      t.index :facility_code, unique: true
    end
  end
end
