# frozen_string_literal: true

module Lcpe
  class ExamTest < ApplicationRecord
    extend SqlContext

    belongs_to :exam

    def self.rebuild
      pure_sql(<<~SQL)
        INSERT INTO #{table_name} (id, exam_id, descp_txt, fee_amt, begin_dt, end_dt)
        SELECT
          o.id,
          x.id AS exam_id,
          o.descp_txt,
          o.fee_amt,
          o.begin_dt,
          o.end_dt
        FROM lcpe_feed_nexams o
        JOIN lcpe_exams x ON o.facility_code = x.facility_code AND o.nexam_nm = x.nexam_nm;
      SQL
    end
  end
end
