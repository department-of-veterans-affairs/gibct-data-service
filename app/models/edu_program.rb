# frozen_string_literal: true

class EduProgram < ImportableRecord
  CSV_CONVERTER_INFO = {
    'facility_code' => { column: :facility_code, converter: FacilityCodeConverter },
    'institution_name' => { column: :institution_name, converter: InstitutionConverter },
    'school_locale' => { column: :school_locale, converter: BaseConverter },
    'provider_website' => { column: :provider_website, converter: BaseConverter },
    'provider_email_address' => { column: :provider_email_address, converter: BaseConverter },
    'phone_area_code' => { column: :phone_area_code, converter: BaseConverter },
    'phone_number' => { column: :phone_number, converter: BaseConverter },
    'student_vet_group' => { column: :student_vet_group, converter: BaseConverter },
    'student_vet_group_website' => { column: :student_vet_group_website, converter: BaseConverter },
    'vet_success_name' => { column: :vet_success_name, converter: BaseConverter },
    'vet_success_email' => { column: :vet_success_email, converter: BaseConverter },
    'vet_tec_program' => { column: :vet_tec_program, converter: BaseConverter },
    'tuition_amount' => { column: :tuition_amount, converter: NumberConverter },
    'program_length' => { column: :length_in_weeks, converter: NumberConverter }
  }.freeze

  validates :facility_code, presence: true
  validates_with EduProgramValidator, on: :after_import
end
