class AddForeignKeyToCalculatorConstants < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_foreign_key :calculator_constants, :cost_of_living_adjustments, validate: false
  end
end
