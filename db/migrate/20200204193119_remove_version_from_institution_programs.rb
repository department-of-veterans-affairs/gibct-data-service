class RemoveVersionFromInstitutionPrograms < ActiveRecord::Migration[5.2]
  def change
    safety_assured { remove_column :institution_programs, :version, :integer }
    safety_assured { remove_column :institution_programs_archives, :version, :integer }
  end
end
