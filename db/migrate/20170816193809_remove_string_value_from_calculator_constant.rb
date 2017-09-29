class RemoveStringValueFromCalculatorConstant < ActiveRecord::Migration
  def change
    remove_column :calculator_constants, :string_value
  end
end
