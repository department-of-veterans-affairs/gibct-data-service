class AddInstitutionColumnsToInstitutionPrograms < ActiveRecord::Migration[5.1]
  def change
    add_column :institution_programs, :institution_name, :string
    add_column :institution_programs, :city, :string
    add_column :institution_programs, :state, :string
    add_column :institution_programs, :country, :string
    add_column :institution_programs, :preferred_provider, :boolean
    add_column :institution_programs, :dod_bah, :int
    add_column :institution_programs, :va_bah, :float
  end
end
