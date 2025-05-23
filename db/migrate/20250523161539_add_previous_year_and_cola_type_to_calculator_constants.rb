class AddPreviousYearAndColaTypeToCalculatorConstants < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :calculator_constants, :previous_year, :float
    add_reference :calculator_constants, :cost_of_living_adjustment, index: { algorithm: :concurrently }
  end
end
