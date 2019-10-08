class RemoveStringValueFromCalculatorConstant < ActiveRecord::Migration[4.2]
  def change
    remove_column :calculator_constants, :string_value
  end
end
