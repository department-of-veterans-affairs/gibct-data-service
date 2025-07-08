class AddForeignKeyToCalculatorConstants < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :calculator_constants, :rate_adjustments, validate: false
  end
end