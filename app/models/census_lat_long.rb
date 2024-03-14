# frozen_string_literal: true

class CensusLatLong < ImportableRecord
  CSV_CONVERTER_INFO = {
    'facility_code' => { column: :facility_code, converter: Converters::BaseConverter },
    'input_address' => { column: :input_address, converter: Converters::BaseConverter },
    'tiger_address_range_match_indicator' => {
      column: :tiger_address_range_match_indicator, converter: Converters::BaseConverter
    },

    'tiger_match_type' => { column: :tiger_match_type, converter: Converters::BaseConverter },
    'tiger_output_address' => { column: :tiger_output_address, converter: Converters::BaseConverter },
    'interpolated_longitude_latitude' => {
      column: :interpolated_longitude_latitude, converter: Converters::BaseConverter
    },

    'tiger_line_id' => { column: :tiger_line_id, converter: Converters::BaseConverter },
    'tiger_line_id_side' => { column: :tiger_line_id_side, converter: Converters::BaseConverter }
  }.freeze
end
