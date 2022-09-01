# frozen_string_literal: true

class SchoolRating < ImportableRecord
  CSV_CONVERTER_INFO = {
    'survey_key' => { column: :rater_id, converter: BaseConverter },
    'email_address' => { column: :email_address, converter: BaseConverter },
    'age' => { column: :age, converter: BaseConverter },
    'gender' => { column: :gender, converter: BaseConverter },
    'school' => { column: :school, converter: BaseConverter },
    'facility_code' => { column: :facility_code, converter: FacilityCodeConverter },
    'degree' => { column: :degree, converter: BaseConverter },
    'graduation_date' => { column: :graduation_date, converter: BaseConverter },
    'benefit_program' => { column: :benefit_program, converter: BaseConverter },
    'enrollment_type' => { column: :enrollment_type, converter: BaseConverter },
    'monthly_payments_benefit' => { column: :monthly_payments_benefit, converter: BaseConverter },
    'payee_number' => { column: :payee_number, converter: BaseConverter },
    'objective_code' => { column: :objective_code, converter: BaseConverter },
    'rated_at' => { column: :rated_at, converter: DateConverter },
    'survey_sent_date' => { column: :survey_sent_date, converter: BaseConverter },
    'overall_experience' => { column: :overall_experience, converter: BaseConverter },
    'gi_bill_support' => { column: :gi_bill_support, converter: BaseConverter },
    'veteran_community' => { column: :veteran_community, converter: BaseConverter },
    'quality_of_classes' => { column: :quality_of_classes, converter: BaseConverter }
  }.freeze

  validates :facility_code, :rater_id, :rated_at, presence: true
end
