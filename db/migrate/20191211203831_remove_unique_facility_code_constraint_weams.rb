class RemoveUniqueFacilityCodeConstraintWeams < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    remove_index :weams, [ :facility_code ]
    add_index :weams, [:facility_code], algorithm: :concurrently
  end
end
