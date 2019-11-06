class UpdateEduPrograms < ActiveRecord::Migration[5.2]
  def change
    change_column_null :edu_programs, :student_vet_group_website, true
    change_column_null :edu_programs, :vet_success_email, true
  end
end
