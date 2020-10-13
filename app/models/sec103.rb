# frozen_string_literal: true

class Sec103 < ApplicationRecord
  COLS_USED_IN_INSTITUTION = %i[complies_with_sec_103 solely_requires_coe requires_coe_and_criteria].freeze

  CSV_CONVERTER_INFO = {
    'facility name' => { column: :name, converter: BaseConverter },
    'facility code' => { column: :facility_code, converter: FacilityCodeConverter },
    'complies with section 103' => { column: :complies_with_sec_103, converter: BooleanConverter },
    'solely requires coe' => { column: :solely_requires_coe, converter: BooleanConverter },
    'requires coe & additional criteria' => { column: :requires_coe_and_criteria, converter: BooleanConverter }
  }.freeze

  validates :facility_code, presence: true
end
