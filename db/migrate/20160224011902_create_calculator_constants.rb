class CreateCalculatorConstants < ActiveRecord::Migration[4.2]
  def change
    create_table :calculator_constants do |t|
      t.string :name
      t.float :float_value, default: nil
      t.string :string_value, default: nil
      t.timestamps null: false
      t.index :name
    end
  end
end
