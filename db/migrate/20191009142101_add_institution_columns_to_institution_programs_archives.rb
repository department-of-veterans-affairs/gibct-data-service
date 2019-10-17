class AddInstitutionColumnsToInstitutionProgramsArchives < ActiveRecord::Migration[5.1]
  def change
    add_column :institution_programs_archives, :institution_id, :integer
  end
end
