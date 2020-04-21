class AddParentFacilityCodeIdIndexToInstitutions < ActiveRecord::Migration[5.2]
    disable_ddl_transaction!
  
    def change
      add_index :institutions, :parent_facility_code_id, algorithm: :concurrently
    end
  end
  