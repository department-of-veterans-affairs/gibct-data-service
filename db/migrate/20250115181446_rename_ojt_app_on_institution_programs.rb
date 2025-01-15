class RenameOjtAppOnInstitutionPrograms < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :institution_programs, :ojt_app }
    add_column :institution_programs, :ojt_app_type, :string
  end
end
