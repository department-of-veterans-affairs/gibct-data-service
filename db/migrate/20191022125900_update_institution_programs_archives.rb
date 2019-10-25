class UpdateInstitutionProgramsArchives < ActiveRecord::Migration[5.2]
  def change
    change_column_null :institution_programs_archives, :facility_code, true
  end
end
