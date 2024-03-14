# frozen_string_literal: true

class Sec103 < ImportableRecord
  COLS_USED_IN_INSTITUTION = %i[complies_with_sec_103 solely_requires_coe requires_coe_and_criteria].freeze

  CSV_CONVERTER_INFO = {
    'facility_name' => { column: :name, converter: Converters::BaseConverter },
    'facility_code' => { column: :facility_code, converter: Converters::FacilityCodeConverter },
    'complies_with_section_103' => { column: :complies_with_sec_103, converter: Converters::BooleanConverter },
    'solely_requires_coe' => { column: :solely_requires_coe, converter: Converters::BooleanConverter },
    'requires_coe_&_additional_criteria' => {
      column: :requires_coe_and_criteria, converter: Converters::BooleanConverter
    }
  }.freeze

  validates :facility_code, presence: true
end
