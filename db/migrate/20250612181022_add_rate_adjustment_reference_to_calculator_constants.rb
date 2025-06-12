class AddRateAdjustmentReferenceToCalculatorConstants < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :calculator_constants, :previous_year, :float
    add_reference :calculator_constants, :rate_adjustment, index: { algorithm: :concurrently }
  end
end
