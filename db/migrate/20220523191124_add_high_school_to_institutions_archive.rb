class AddHighSchoolToInstitutionsArchive < ActiveRecord::Migration[6.1]
  def change
    add_column :institutions_archives, :high_school, :boolean, default: false
  end
end
