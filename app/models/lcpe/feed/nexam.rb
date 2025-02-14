# frozen_string_literal: true

module Lcpe
  module Feed
    class Nexam < ImportableRecord
      extend SqlContext

      CSV_CONVERTER_INFO = {
        'facility_code' => { column: :facility_code, converter: Converters::BaseConverter },
        'national_exam_name' => { column: :nexam_nm, converter: Converters::BaseConverter },
        'nexam_fee_description' => { column: :descp_txt, converter: Converters::BaseConverter },
        'nexam_fee_amount' => { column: :fee_amt, converter: Converters::BaseConverter },
        'nexam_fee_from_date' => { column: :begin_dt, converter: Converters::BaseConverter },
        'nexam_fee_to_date' => { column: :end_dt, converter: Converters::BaseConverter }
      }.freeze

      LCPE_TYPE = 'Lcpe::Exam'

      def self.normalize
        pure_sql
          .join(Lcpe::Exam.reset)
          .join(Lcpe::ExamTest.reset)
      end
    end
  end
end
