module Lcpe
  module Feed
    class Lac < ImportableRecord
      extend Edm::SqlContext

      CSV_CONVERTER_INFO = {
        'facility_code' => { column: :facility_code, converter: Converters::BaseConverter },
        'lc_type' => { column: :edu_lac_type_nm, converter: Converters::BaseConverter },
        'lc_name' => { column: :lac_nm, converter: Converters::BaseConverter },
        'lc_test_name' => { column: :test_nm, converter: Converters::BaseConverter },
        'lc_test_fee' => { column: :fee_amt, converter: Converters::BaseConverter }
      }.freeze

      def self.normalize
        pure_sql
          .join(Lcpe::Lac.reset)
          .join(Lcpe::LacTest.reset)
      end    
    end
  end
end
