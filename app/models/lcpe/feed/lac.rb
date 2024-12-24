module Lcpe
  module Feed
    class Lac < ImportableRecord
      CSV_CONVERTER_INFO = {
        'facility_code' => { column: :facility_code, converter: Converters::BaseConverter },
        'edu_lac_type_nm' => { column: :edu_lac_type_nm, converter: Converters::BaseConverter },
        'lac_nm' => { column: :lac_nm, converter: Converters::BaseConverter },
        'test_nm' => { column: :test_nm, converter: Converters::BaseConverter },
        'fee_amt' => { column: :fee_amt, converter: Converters::BaseConverter }
      }.freeze
    end
  end
end
