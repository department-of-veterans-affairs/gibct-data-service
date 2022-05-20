class AddHighSchoolToWeamAndInstitution < ActiveRecord::Migration[6.1]
  def change
    add_column :weams, :high_school, :boolean, default: false
    add_column :institutions, :high_school, :boolean, default: false
  end
end
