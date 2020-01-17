class AddInstitutionColumnsToSchoolCertifyingOfficials < ActiveRecord::Migration[5.2]
  def change
    add_column :school_certifying_officials, :institution_id, :integer
  end
end
