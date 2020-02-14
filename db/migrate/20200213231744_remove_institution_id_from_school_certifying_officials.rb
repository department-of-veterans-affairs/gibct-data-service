class RemoveInstitutionIdFromSchoolCertifyingOfficials < ActiveRecord::Migration[5.2]
  def change
    safety_assured { remove_column :school_certifying_officials, :institution_id, :bigint }
  end
end
