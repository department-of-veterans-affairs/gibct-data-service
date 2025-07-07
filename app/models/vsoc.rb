# frozen_string_literal: true

class Vsoc < ImportableRecord
  COLS_USED_IN_INSTITUTION = %i[vetsuccess_name vetsuccess_email].freeze

  CSV_CONVERTER_INFO = {
    'facility_code' => { column: :facility_code, converter: Converters::FacilityCodeConverter },
    'institution' => { column: :institution, converter: Converters::InstitutionConverter },
    'vetsuccess_name' => { column: :vetsuccess_name, converter: Converters::BaseConverter },
    'vetsuccess_email' => { column: :vetsuccess_email, converter: Converters::BaseConverter }
  }.freeze

  API_SOURCE = 'https://vbaw.vba.va.gov/EDUCATION/job_aids/documents/'

  validates :facility_code, presence: true
end
