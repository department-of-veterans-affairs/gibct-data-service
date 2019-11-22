class AllowNullsEduPrograms < ActiveRecord::Migration[5.2]
  def change
    change_column_null :edu_programs, :facility_code, true
    change_column_null :edu_programs, :institution_name, true
    change_column_null :edu_programs, :school_locale, true
    change_column_null :edu_programs, :provider_website, true
    change_column_null :edu_programs, :provider_email_address, true
    change_column_null :edu_programs, :phone_area_code, true
    change_column_null :edu_programs, :phone_number, true
    change_column_null :edu_programs, :student_vet_group, true
    change_column_null :edu_programs, :student_vet_group_website, true
    change_column_null :edu_programs, :vet_success_name, true
    change_column_null :edu_programs, :vet_success_email, true
    change_column_null :edu_programs, :vet_tec_program, true
    change_column_null :edu_programs, :tuition_amount, true
    change_column_null :edu_programs, :length_in_weeks, true
  end
end
