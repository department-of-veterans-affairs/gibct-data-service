class CreateInstitutionSchoolRatings < ActiveRecord::Migration[6.1]
  def change
    create_table :institution_school_ratings do |t|
      t.string  :survey_key
      t.string  :email
      t.string  :age
      t.string  :gender
      t.string  :school
      t.string  :facility_code
      t.string  :degree
      t.date    :graduation_date
      t.string  :benefit_program
      t.string  :enrollment_type
      t.string  :monthly_payment_benefit
      t.string  :payee_number
      t.string  :objective_code
      t.date    :response_date
      t.date    :sent_date
      t.integer :q1    # Instructors' knowledge in the subject being taught
      t.integer :q2    # Instructors' ability to engage with students around course content
      t.integer :q3    # Support of course materials in meeting learning objectives
      t.integer :q4    # Contribution of school-supplied technology and/or facilities to successful learning experience
      t.integer :q5    # Contribution of learning experience to skills needed for career journey
      t.string  :q6    # Did you interact with the School Certifying Officials (school staff who assist Veterans/beneficiaries with enrollment, submit documentation to VA, advise on other VA benefits)?
      t.integer :q7    # Supportiveness of School Certifying Officials (school staff who assist Veterans/beneficiaries with enrollment, submit documentation to VA, advise on other VA benefits)
      t.integer :q8    # Availability of School Certifying Officials (school staff who assist Veterans/beneficiaries with enrollment, submit documentation to VA, advise on other VA benefits)
      t.integer :q9    # School's timely completion of VA enrollment documentation
      t.integer :q10   # Helpfulness of school-provided information about GI Bill, other VA benefits
      t.integer :q11   # Extent of school's support for its Veteran community
      t.integer :q12   # Extent of support from others in the school's Veteran community
      t.integer :q13   # Overall learning experience
      t.integer :q14   # Overall school experience
      t.integer :q15   # for future use
      t.integer :q16   # for future use
      t.integer :q17   # for future use
      t.integer :q18   # for future use
      t.integer :q19   # for future use
      t.integer :q20   # for future use
    end
  end
end
