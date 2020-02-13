
class AddInstitutionIdToVersionedSchoolCertifyingOfficials < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :versioned_school_certifying_officials, :institution, foreign_key: true, index: false
    add_index :versioned_school_certifying_officials, :institution_id, algorithm: :concurrently
  end
end

