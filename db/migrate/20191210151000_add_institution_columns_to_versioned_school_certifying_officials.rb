class AddInstitutionColumnsToVersionedSchoolCertifyingOfficials < ActiveRecord::Migration[5.1]
  def change
    add_column :versioned_school_certifying_officials, :institution_id, :integer
  end
end
