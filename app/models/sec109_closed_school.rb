# frozen_string_literal: true

class Sec109ClosedSchool < ApplicationRecord


  COLS_USED_IN_INSTITUTION = %i[closure109].freeze

  CSV_CONVERTER_INFO = {
    'facility_code' => { column: :facility_code, converter: FacilityCodeConverter },
    'school_name' => { column: :school_name, converter: InstitutionConverter },
    'closure109' => { column: :closure109, converter: BooleanConverter }
  }.freeze

  validates :facility_code, presence: true
end
