class AddOjtAppTypeToInstitutionPrograms < ActiveRecord::Migration[7.1]
  def change
    add_column :institution_programs, :ojt_app_type, :string
  end
end
