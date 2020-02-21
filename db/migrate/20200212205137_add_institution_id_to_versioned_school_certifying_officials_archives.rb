class AddInstitutionIdToVersionedSchoolCertifyingOfficialsArchives < ActiveRecord::Migration[5.2]
  def change
    add_column :versioned_school_certifying_officials_archives, :institution_id, :bigint
  end
end
