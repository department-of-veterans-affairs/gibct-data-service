class RemoveInstitutionIdFromSchoolCertifyingOfficials < ActiveRecord::Migration[5.2]
  def change
    safety_assured { remove_reference :school_certifying_officials, :institution, index: true, foreign_key: true }
  end
end
