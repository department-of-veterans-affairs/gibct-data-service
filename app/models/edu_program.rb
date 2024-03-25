# frozen_string_literal: true

class EduProgram < ImportableRecord
  CSV_CONVERTER_INFO = {
    'facility_code' => { column: :facility_code, converter: Converters::FacilityCodeConverter },
    'institution_name' => { column: :institution_name, converter: Converters::InstitutionConverter },
    'school_locale' => { column: :school_locale, converter: Converters::BaseConverter },
    'provider_website' => { column: :provider_website, converter: Converters::BaseConverter },
    'provider_email_address' => { column: :provider_email_address, converter: Converters::BaseConverter },
    'phone_area_code' => { column: :phone_area_code, converter: Converters::BaseConverter },
    'phone_number' => { column: :phone_number, converter: Converters::BaseConverter },
    'student_vet_group' => { column: :student_vet_group, converter: Converters::BaseConverter },
    'student_vet_group_website' => { column: :student_vet_group_website, converter: Converters::BaseConverter },
    'vet_success_name' => { column: :vet_success_name, converter: Converters::BaseConverter },
    'vet_success_email' => { column: :vet_success_email, converter: Converters::BaseConverter },
    'vet_tec_program' => { column: :vet_tec_program, converter: Converters::BaseConverter },
    'tuition_amount' => { column: :tuition_amount, converter: Converters::NumberConverter },
    'program_length' => { column: :length_in_weeks, converter: Converters::NumberConverter }
  }.freeze

  validates :facility_code, presence: true
  validates_with EduProgramValidator, on: :after_import
end
