class AddInstitutionColumnsToSchoolCertifyingOfficials < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :school_certifying_officials, :institution, foreign_key: true, index: false
    add_index :school_certifying_officials, :institution_id, algorithm: :concurrently
  end
end
