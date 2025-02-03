# frozen_string_literal: true

module Lcpe
  class Exam < ApplicationRecord
    REF_CODE_FN = "RIGHT(MD5(CONCAT(facility_code, '-', nexam_nm)), 5)"

    extend SqlContext

    # using Enriched IDs is a good way to ensure that
    # a stale ID preloaded from the browser is not used.
    scope :with_enriched_id, lambda {
      select(
        '*',
        "#{REF_CODE_FN} AS ref_code",
        "CONCAT(id, '@', #{REF_CODE_FN}) enriched_id"
      )
    }

    scope :by_enriched_id, lambda { |enriched_id|
      id, = enriched_id.match(/\A(\d+)@(.+)\z/).values_at(1, 2)

        with(enriched_query: with_enriched_id.where('id = ?', id))
          .select("#{table_name}.*", 'enriched_query.enriched_id')
          .from(table_name.to_s)
          .joins("LEFT JOIN enriched_query ON #{table_name}.id = enriched_query.id")
          .where('enriched_query.enriched_id = ?', enriched_id)
    }

    has_many :tests, class_name: 'ExamTest', dependent: :destroy

    # rubocop:disable Rails/InverseOf
    belongs_to(
      :institution,
      foreign_key: :facility_code,
      primary_key: :facility_code
    )
    # rubocop:enable Rails/InverseOf

    # rubocop:disable Rails/InverseOf
    belongs_to(
      :weam,
      foreign_key: :facility_code,
      primary_key: :facility_code
    )
    # rubocop:enable Rails/InverseOf

    def self.rebuild
      pure_sql(<<~SQL)
        INSERT INTO #{table_name} (id, facility_code, nexam_nm)
        SELECT
          ROW_NUMBER() OVER () AS id,
          facility_code,
          nexam_nm
        FROM (
          SELECT DISTINCT ON (facility_code, nexam_nm)
            facility_code,
            nexam_nm
          FROM lcpe_feed_nexams
        ) subquery;
        CREATE INDEX ON #{table_name} (facility_code);
        CREATE INDEX ON #{table_name} (nexam_nm);
      SQL
    end
  end
end
