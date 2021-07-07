class AddSearchIndexesToInstitution < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!
  def change
    add_index :institutions, [:institution_search], algorithm: :concurrently
    add_index :institutions, [:ialias], algorithm: :concurrently
    add_index :institutions, [:facility_code, :institution, :ialias], algorithm: :concurrently
    add_index :institutions, [:facility_code, :institution_search, :ialias], algorithm: :concurrently, name: 'index_institutions_on_facility_code_institution_search_ialias'
  end
end
