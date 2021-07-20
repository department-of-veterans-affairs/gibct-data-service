class AddSchoolsEmployersToInstitutionsArchive < ActiveRecord::Migration[6.0]
  def change
    add_column :institutions_archives, :employer_provider, :boolean
    add_column :institutions_archives, :school_provider, :boolean
  end
end
