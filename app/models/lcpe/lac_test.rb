# frozen_string_literal: true

module Lcpe
  class LacTest < ApplicationRecord
    extend SqlContext

    belongs_to :lac

    def self.rebuild
      pure_sql(<<~SQL)
        INSERT INTO #{table_name} (id, lac_id, test_nm, fee_amt)
        SELECT
          o.id,
          x.id AS lac_id,
          o.test_nm,
          o.fee_amt
        FROM lcpe_feed_lacs o
        JOIN lcpe_lacs x ON o.facility_code = x.facility_code AND o.lac_nm = x.lac_nm;
      SQL
    end
  end  
end
