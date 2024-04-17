# frozen_string_literal: true

class Sec109ClosedSchool < ImportableRecord
  COLS_USED_IN_INSTITUTION = %i[closure109].freeze

  CSV_CONVERTER_INFO = {
    'facility_code' => { column: :facility_code, converter: Converters::FacilityCodeConverter },
    'school_name' => { column: :school_name, converter: Converters::InstitutionConverter },
    'closure109' => { column: :closure109, converter: Converters::BooleanConverter }
  }.freeze

  validates :facility_code, presence: true
end
