class AddIndexesToInstitutionBuilder < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    add_index :ipeds_ic_ays, :cross, algorithm: :concurrently
    add_index :ipeds_ic_pies, :cross, algorithm: :concurrently
    add_index :school_certifying_officials, :facility_code, algorithm: :concurrently
    add_index :sec109_closed_schools, :facility_code, algorithm: :concurrently
    add_index :hcms, :ope6, algorithm: :concurrently
  end
end
