class AddInstitutionColumnsToInstitutionPrograms < ActiveRecord::Migration[5.1]
  def change
    add_column :institution_programs, :institution_id, :integer
  end
end
