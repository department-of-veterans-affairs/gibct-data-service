class AddParentFacilityCodeIndexToIntititutions < ActiveRecord::Migration
  disable_ddl_transaction!
  def change
    add_index :institutions, [:version, :parent_facility_code_id] , using: :btree, algorithm: :concurrently
  end
end
