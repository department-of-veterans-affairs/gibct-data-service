class AddOjtAppToInstitutionProgramsArchives < ActiveRecord::Migration[7.1]
  def change
    add_column :institution_programs_archives, :ojt_app, :string
  end
end
