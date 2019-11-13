# frozen_string_literal: true

class EduProgram < ApplicationRecord
  include CsvHelper

  CSV_CONVERTER_INFO = {
    'facility code' => { column: :facility_code, converter: FacilityCodeConverter },
    'institution name' => { column: :institution_name, converter: InstitutionConverter },
    'school locale' => { column: :school_locale, converter: BaseConverter },
    'provider website' => { column: :provider_website, converter: BaseConverter },
    'provider email address' => { column: :provider_email_address, converter: BaseConverter },
    'phone area code' => { column: :phone_area_code, converter: BaseConverter },
    'phone number' => { column: :phone_number, converter: BaseConverter },
    'student vet group' => { column: :student_vet_group, converter: BaseConverter },
    'student vet group website' => { column: :student_vet_group_website, converter: BaseConverter },
    'vet success name' => { column: :vet_success_name, converter: BaseConverter },
    'vet success email' => { column: :vet_success_email, converter: BaseConverter },
    'vet tec program' => { column: :vet_tec_program, converter: BaseConverter },
    'tuition amount' => { column: :tuition_amount, converter: NumberConverter },
    'program length' => { column: :length_in_weeks, converter: NumberConverter }
  }.freeze

  validates_with EduProgramValidator, on: :after_import
end
