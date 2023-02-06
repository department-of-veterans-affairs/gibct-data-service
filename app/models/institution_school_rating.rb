# frozen_string_literal: true

class InstitutionSchoolRating < ImportableRecord
  # keys need an underscore instead of spaces or hyphens because the converter replaces them with underscores
  CSV_CONVERTER_INFO = {
    'survey_key' => { column: :survey_key, converter: UpcaseConverter },
    'email' => { column: :email, converter: BaseConverter },
    'age' => { column: :age, converter: NumberConverter },
    'gender' => { column: :gender, converter: UpcaseConverter },
    'school' => { column: :school, converter: UpcaseConverter },
    'facility_code' => { column: :facility_code, converter: FacilityCodeConverter },
    'degree' => { column: :degree, converter: UpcaseConverter },
    'graduation_date' => { column: :graduation_date, converter: DateConverter },
    'benefit_program' => { column: :benefit_program, converter: UpcaseConverter },
    'enrollment_type' => { column: :enrollment_type, converter: UpcaseConverter },
    'monthly_payment_benefit' => { column: :monthly_payment_benefit, converter: BooleanConverter },
    'payee_number' => { column: :payee_number, converter: BaseConverter },
    'objective_code' => { column: :objective_code, converter: BaseConverter },
    'feedback_received_(et)' => { column: :response_date, converter: DateTimeConverter },
    'survey_sent_date_(et)' => { column: :sent_date, converter: DateTimeConverter },
    "instructors'_knowledge_in_the_subject_being_taught" => { column: :q1, converter: NumberConverter },
    "instructors'_ability_to_engage_with_students_around_course_content" => { column: :q2, converter: NumberConverter },
    'support_of_course_materials_in_meeting_learning_objectives' => { column: :q3, converter: NumberConverter },
    'contribution_of_school_supplied_technology_and/or_facilities_to_successful_learning_experience' => { column: :q4, converter: NumberConverter },
    'contribution_of_learning_experience_to_skills_needed_for_career_journey' => { column: :q5, converter: NumberConverter },
    'did_you_interact_with_the_school_certifying_officials_(school_staff_who_assist_veterans/beneficiaries_with_enrollment,_submit_documentation_to_va,_advise_on_other_va_benefits)?' => { column: :q6, converter: BaseConverter },
    'supportiveness_of_school_certifying_officials_(school_staff_who_assist_veterans/beneficiaries_with_enrollment,_submit_documentation_to_va,_advise_on_other_va_benefits)' => { column: :q7, converter: NumberConverter },
    'availability_of_school_certifying_officials_(school_staff_who_assist_veterans/beneficiaries_with_enrollment,_submit_documentation_to_va,_advise_on_other_va_benefits)' => { column: :q8, converter: NumberConverter },
    "school's_timely_completion_of_va_enrollment_documentation" => { column: :q9, converter: NumberConverter },
    'helpfulness_of_school_provided_information_about_gi_bill,_other_va_benefits' => { column: :q10, converter: NumberConverter },
    "extent_of_school's_support_for_its_veteran_community" => { column: :q11, converter: NumberConverter },
    "extent_of_support_from_others_in_the_school's_veteran_community" => { column: :q12, converter: NumberConverter },
    'overall_learning_experience' => { column: :q13, converter: NumberConverter },
    'overall_school_experience' => { column: :q14, converter: NumberConverter }
  }.freeze

  validates :facility_code, presence: true
end
