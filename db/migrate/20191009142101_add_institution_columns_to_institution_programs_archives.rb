class AddInstitutionColumnsToInstitutionProgramsArchives < ActiveRecord::Migration[5.1]
  def change
    add_column :institution_programs_archives, :institution_name, :string
    add_column :institution_programs_archives, :city, :string
    add_column :institution_programs_archives, :state, :string
    add_column :institution_programs_archives, :country, :string
    add_column :institution_programs_archives, :preferred_provider, :boolean
    add_column :institution_programs_archives, :dod_bah, :int
    add_column :institution_programs_archives, :va_bah, :float
  end
end
