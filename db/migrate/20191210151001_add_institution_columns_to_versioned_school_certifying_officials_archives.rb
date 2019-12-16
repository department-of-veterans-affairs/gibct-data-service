class AddInstitutionColumnsToVersionedSchoolCertifyingOfficialsArchives < ActiveRecord::Migration[5.1]
  def change
    add_column :versioned_school_certifying_officials_archives, :institution_id, :integer
  end
end
