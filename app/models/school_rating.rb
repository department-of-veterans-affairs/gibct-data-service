# frozen_string_literal: true

# TODO: remove when we write new ratings code
class SchoolRating < ImportableRecord
  CSV_CONVERTER_INFO = {
    'survey_key' => { column: :rater_id, converter: BaseConverter },
    'email_address' => { column: :email_address, converter: BaseConverter },
    'age' => { column: :age, converter: BaseConverter },
    'gender' => { column: :gender, converter: BaseConverter },
    'school' => { column: :school, converter: BaseConverter },
    'facility_code' => { column: :facility_code, converter: FacilityCodeConverter },
    'degree' => { column: :degree, converter: BaseConverter },
    'graduation_date' => { column: :graduation_date, converter: DateConverter },
    'benefit_program' => { column: :benefit_program, converter: BaseConverter },
    'enrollment_type' => { column: :enrollment_type, converter: BaseConverter },
    'monthly_payments_benefit' => { column: :monthly_payments_benefit, converter: BaseConverter },
    'payee_number' => { column: :payee_number, converter: BaseConverter },
    'objective_code' => { column: :objective_code, converter: BaseConverter },
    'rated_at' => { column: :rated_at, converter: DateConverter },
    'survey_sent_date' => { column: :survey_sent_date, converter: DateConverter },
    'instructor_knowledge' => { column: :instructor_knowledge, converter: BaseConverter },
    'instructor_engagement' => { column: :instructor_engagement, converter: BaseConverter },
    'course_material_support' => { column: :course_material_support, converter: BaseConverter },
    'succesful_learning_experience' => { column: :succesful_learning_experience, converter: BaseConverter },
    'contribution_career_learning' => { column: :contribution_career_learning_experience, converter: BaseConverter },
    'interact_school_officials' => { column: :interact_school_officials, converter: BaseConverter },
    'support_school_officials' => { column: :support_school_officials, converter: BaseConverter },
    'avail_school_officials' => { column: :avail_school_officials, converter: BaseConverter },
    'timely_completion_docs' => { column: :timely_completion_docs, converter: BaseConverter },
    'helpfulness_school' => { column: :helpfulness_school, converter: BaseConverter },
    'extent_support_school' => { column: :extent_support_school, converter: BaseConverter },
    'extent_support_others' => { column: :extent_support_others, converter: BaseConverter },
    'overall_learning_experience' => { column: :overall_learning_experience, converter: BaseConverter },
    'overall_school_experience' => { column: :overall_school_experience, converter: BaseConverter },
    'overall_experience' => { column: :overall_experience, converter: BaseConverter },
    'gi_bill_support' => { column: :gi_bill_support, converter: BaseConverter },
    'veteran_community' => { column: :veteran_community, converter: BaseConverter },
    'quality_of_classes' => { column: :quality_of_classes, converter: BaseConverter }
  }.freeze

  validates :facility_code, :rater_id, :rated_at, presence: true
end
