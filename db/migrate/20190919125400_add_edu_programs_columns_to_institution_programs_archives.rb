class AddEduProgramsColumnsToInstitutionProgramsArchives < ActiveRecord::Migration
  def change
    add_column :institution_programs_archives, :school_locale, :string
    add_column :institution_programs_archives, :provider_website, :string
    add_column :institution_programs_archives, :provider_email_address, :string
    add_column :institution_programs_archives, :phone_area_code, :string
    add_column :institution_programs_archives, :phone_number, :string
    add_column :institution_programs_archives, :student_vet_group, :string
    add_column :institution_programs_archives, :student_vet_group_website, :string
    add_column :institution_programs_archives, :vet_success_name, :string
    add_column :institution_programs_archives, :vet_success_email, :string
    add_column :institution_programs_archives, :vet_tec_program, :string
    add_column :institution_programs_archives, :tuition_amount, :integer
    add_column :institution_programs_archives, :length_in_weeks, :integer
  end   
end
