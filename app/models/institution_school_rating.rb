# frozen_string_literal: true

class InstitutionSchoolRating < ImportableRecord
  # keys need an underscore instead of spaces or hyphens because the converter replaces them with underscores
  CSV_CONVERTER_INFO = {
    'survey_key' => { column: :survey_key, converter: Converters::UpcaseConverter },
    'age' => { column: :age, converter: Converters::NumberConverter },
    'gender' => { column: :gender, converter: Converters::UpcaseConverter },
    'school' => { column: :school, converter: Converters::UpcaseConverter },
    'facility_code' => { column: :facility_code, converter: Converters::FacilityCodeConverter },
    'degree' => { column: :degree, converter: Converters::UpcaseConverter },
    'graduation_date' => { column: :graduation_date, converter: Converters::DateConverter },
    'benefit_program' => { column: :benefit_program, converter: Converters::UpcaseConverter },
    'enrollment_type' => { column: :enrollment_type, converter: Converters::UpcaseConverter },
    'monthly_payment_benefit' => { column: :monthly_payment_benefit, converter: Converters::BooleanConverter },
    'payee_number' => { column: :payee_number, converter: Converters::BaseConverter },
    'objective_code' => { column: :objective_code, converter: Converters::BaseConverter },
    'feedback_received_(et)' => { column: :response_date, converter: Converters::DateTimeConverter },
    'survey_sent_date_(et)' => { column: :sent_date, converter: Converters::DateTimeConverter },
    "instructors'_knowledge_in_the_subject_being_taught" => { column: :q1, converter: Converters::NumberConverter },
    "instructors'_ability_to_engage_with_students_around_course_content" => { column: :q2, converter: Converters::NumberConverter },
    'support_of_course_materials_in_meeting_learning_objectives' => { column: :q3, converter: Converters::NumberConverter },
    'contribution_of_school_supplied_technology_and/or_facilities_to_successful_learning_experience' => { column: :q4, converter: Converters::NumberConverter },
    'contribution_of_learning_experience_to_skills_needed_for_career_journey' => { column: :q5, converter: Converters::NumberConverter },
    'did_you_interact_with_the_school_certifying_officials_(school_staff_who_assist_veterans/beneficiaries_with_enrollment,_submit_documentation_to_va,_advise_on_other_va_benefits)?' => { column: :q6, converter: Converters::BaseConverter },
    'supportiveness_of_school_certifying_officials_(school_staff_who_assist_veterans/beneficiaries_with_enrollment,_submit_documentation_to_va,_advise_on_other_va_benefits)' => { column: :q7, converter: Converters::NumberConverter },
    'availability_of_school_certifying_officials_(school_staff_who_assist_veterans/beneficiaries_with_enrollment,_submit_documentation_to_va,_advise_on_other_va_benefits)' => { column: :q8, converter: Converters::NumberConverter },
    "school's_timely_completion_of_va_enrollment_documentation" => { column: :q9, converter: Converters::NumberConverter },
    'helpfulness_of_school_provided_information_about_gi_bill,_other_va_benefits' => { column: :q10, converter: Converters::NumberConverter },
    "extent_of_school's_support_for_its_veteran_community" => { column: :q11, converter: Converters::NumberConverter },
    "extent_of_support_from_others_in_the_school's_veteran_community" => { column: :q12, converter: Converters::NumberConverter },
    'overall_learning_experience' => { column: :q13, converter: Converters::NumberConverter },
    'overall_school_experience' => { column: :q14, converter: Converters::NumberConverter }
  }.freeze

  validates :facility_code, presence: true
end
