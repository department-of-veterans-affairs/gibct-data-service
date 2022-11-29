class CreateInstitutionSchoolRatings < ActiveRecord::Migration[6.1]
  def change
    create_table :institution_school_ratings do |t|
      t.string :survey_person_id
      t.string :email_address
      t.date :graduation_date
      t.string :facility_code
      t.string :facility_participant_name
      t.string :program_name
      t.string :first_name
      t.string :last_name
      t.string :objective_code
      t.string :enrollment_type
      t.string :benefit_type
      t.string :payee_num
      t.string :monthly_payment_benefit
      t.string :age
      t.string :gender
      t.string :survey_id
      t.date :sent_date
      t.date :response_date
      t.string :e_status
      t.integer :q1
      t.integer :q2
      t.integer :q3
      t.integer :q4
      t.integer :q5
      t.integer :q6
      t.integer :q7
      t.integer :q8
      t.integer :q9
      t.integer :q10
      t.integer :q11
      t.integer :q12
      t.integer :q13
      t.integer :q14
    end
  end
end
