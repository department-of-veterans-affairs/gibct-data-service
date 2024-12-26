module Lcpe
  module Feed
    class Nexam < ImportableRecord
      extend Edm::SqlContext
    
      CSV_CONVERTER_INFO = {
        'facility_code' => { column: :facility_code, converter: Converters::BaseConverter },
        'nexam_nm' => { column: :nexam_nm, converter: Converters::BaseConverter },
        'descp_txt' => { column: :descp_txt, converter: Converters::BaseConverter },
        'fee_amt' => { column: :fee_amt, converter: Converters::BaseConverter },
        'begin_dt' => { column: :begin_dt, converter: Converters::BaseConverter },
        'end_dt' => { column: :end_dt, converter: Converters::BaseConverter }
      }.freeze
    end
  end
end
