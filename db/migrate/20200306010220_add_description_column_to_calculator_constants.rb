class AddDescriptionColumnToCalculatorConstants < ActiveRecord::Migration[5.2]
  def change
    add_column :calculator_constants, :description, :string
  end
end
