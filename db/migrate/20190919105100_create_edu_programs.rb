class CreateEduPrograms < ActiveRecord::Migration
  def change
    create_table :edu_programs do |t|
      t.string :facility_code, null: false
      t.string :institution_name, null: false
      t.string :school_locale, null: false
      t.string :provider_website, null: false
      t.string :provider_email_address, null: false
      t.string :phone_area_code, null: false
      t.string :phone_number, null: false
      t.string :student_vet_group, null: false
      t.string :student_vet_group_website, null: false
      t.string :vet_success_name, null: false
      t.string :vet_success_email, null: false
      t.string :vet_tec_program, null: false
      t.string :tuition_amount, null: false
      t.string :program_length, null: false
    end
  end
end
