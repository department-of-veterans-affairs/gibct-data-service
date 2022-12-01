class InstitutionSchoolRating < ImportableRecord
  CSV_CONVERTER_INFO = {
    'survey_person_id' => { column: :survey_person_id, converter: UpcaseConverter },
    'email_address' => { column: :email_address, converter: BaseConverter },
    'graduation_date' => { column: :graduation_date, converter: DateConverter },
    'facility_code' => { column: :facility_code, converter: FacilityCodeConverter },
    'facility_participant_name' => { column: :facility_participant_name, converter: InstitutionConverter },
    'program_name' => { column: :program_name, converter: UpcaseConverter },
    'first_name' => { column: :first_name, converter: BaseConverter },
    'last_name' => { column: :last_name, converter: BaseConverter },
    'objective_code' => { column: :objective_code, converter: BaseConverter },
    'enrollment_type' => { column: :enrollment_type, converter: UpcaseConverter },
    'benefit_type' => { column: :benefit_type, converter: BaseConverter },
    'payee_num' => { column: :payee_num, converter: BaseConverter },
    'monthly_payment_benefit' => { column: :monthly_payment_benefit, converter: BooleanConverter },
    'age' => { column: :age, converter: NumberConverter },
    'gender' => { column: :gender, converter: UpcaseConverter },
    'survey_id' => { column: :survey_id, converter: UpcaseConverter },
    'sent_date' => { column: :sent_date, converter: DateConverter },
    'response_date' => { column: :response_date, converter: DateConverter },
    'e_status' => { column: :e_status, converter: NumberConverter },
    'q1' => { column: :q1, converter: NumberConverter },
    'q2' => { column: :q2, converter: NumberConverter },
    'q3' => { column: :q3, converter: NumberConverter },
    'q4' => { column: :q4, converter: NumberConverter },
    'q5' => { column: :q5, converter: NumberConverter },
    'q6' => { column: :q6, converter: NumberConverter },
    'q7' => { column: :q7, converter: NumberConverter },
    'q8' => { column: :q8, converter: NumberConverter },
    'q9' => { column: :q9, converter: NumberConverter },
    'q10' => { column: :q10, converter: NumberConverter },
    'q11' => { column: :q11, converter: NumberConverter },
    'q12' => { column: :q12, converter: NumberConverter },
    'q13' => { column: :q13, converter: NumberConverter },
    'q14' => { column: :q14, converter: NumberConverter }
  }.freeze
  
  validates :facility_code, presence: true
end
