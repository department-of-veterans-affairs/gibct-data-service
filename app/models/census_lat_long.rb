# frozen_string_literal: true

class CensusLatLong < ImportableRecord
  CSV_CONVERTER_INFO = {
    'facility_code' => { column: :facility_code, converter: BaseConverter },
    'input_address' => { column: :input_address, converter: BaseConverter },
    'tiger_address_range_match_indicator' => { column: :tiger_address_range_match_indicator, converter: BaseConverter },
    'tiger_match_type' => { column: :tiger_match_type, converter: BaseConverter },
    'tiger_output_address' => { column: :tiger_output_address, converter: BaseConverter },
    'interpolated_longitude_latitude' => { column: :interpolated_longitude_latitude, converter: BaseConverter },
    'tiger_line_id' => { column: :tiger_line_id, converter: BaseConverter },
    'tiger_line_id_side' => { column: :tiger_line_id_side, converter: BaseConverter }
  }.freeze
end
