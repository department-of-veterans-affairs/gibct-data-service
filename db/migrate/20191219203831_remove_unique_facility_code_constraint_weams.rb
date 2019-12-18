class RemoveUniqueFacilityCodeConstraintWeams < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    remove_index :weams, [ :facility_code ]
    add_index :weams, [:facility_code], algorithm: :concurrently
  end

  def down
    remove_index :weams, [ :facility_code ]
    add_index :weams, [:facility_code], unique: true, algorithm: :concurrently
  end
end
