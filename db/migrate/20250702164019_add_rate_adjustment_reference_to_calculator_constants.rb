class AddRateAdjustmentReferenceToCalculatorConstants < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :calculator_constants, :rate_adjustment, index: { algorithm: :concurrently }
  end
end