class AddEduProgramsColumnsToInstitutionPrograms < ActiveRecord::Migration
  def change
    add_column :institution_programs, :school_locale, :string
    add_column :institution_programs, :provider_website, :string
    add_column :institution_programs, :provider_email_address, :string
    add_column :institution_programs, :phone_area_code, :string
    add_column :institution_programs, :phone_number, :string
    add_column :institution_programs, :student_vet_group, :string
    add_column :institution_programs, :student_vet_group_website, :string
    add_column :institution_programs, :vet_success_name, :string
    add_column :institution_programs, :vet_success_email, :string
    add_column :institution_programs, :vet_tec_program, :string
    add_column :institution_programs, :tuition_amount, :integer
    add_column :institution_programs, :program_length, :integer
  end   
end
