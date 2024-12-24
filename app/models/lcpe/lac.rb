# frozen_string_literal: true

module Lcpe
  class Lac < ApplicationRecord
    REF_CODE_FN = "RIGHT(MD5(CONCAT(facility_code, '-', lac_nm)), 5)"

    extend Edm::SqlContext

    # using Enriched IDs is a good way to ensure that 
    # a stale ID preloaded from the browser is not used.
    scope :with_enriched_id, -> {
      select(
        '*',
        "#{REF_CODE_FN} AS ref_code",
        "CONCAT(id, '@', #{REF_CODE_FN}) enriched_id"
      )
    }

    scope :by_enriched_id, ->(enriched_id) {
      id, ref_code = enriched_id.match(/\A(\d+)@(.+)\z/).values_at(1, 2)
      self
        .with(enriched_query: with_enriched_id.where('id = ?', id))
        .select("#{table_name}.*", 'enriched_query.enriched_id')
        .from("#{table_name}")
        .joins("LEFT JOIN enriched_query ON #{table_name}.id = enriched_query.id")
        .where('enriched_query.enriched_id = ?', enriched_id)
    }

    has_many :tests, class_name: 'LacTest', foreign_key: 'lac_id'

    belongs_to(
      :institution,
      foreign_key: :facility_code,
      primary_key: :facility_code
    )

    belongs_to(
      :weam,
      foreign_key: :facility_code,
      primary_key: :facility_code
    )

    def self.rebuild
      pure_sql(<<~SQL)
        INSERT INTO #{table_name} (id, facility_code, edu_lac_type_nm, state, lac_nm)
        SELECT
          ROW_NUMBER() OVER () AS id,
          subquery.facility_code,
          CASE
            WHEN subquery.facility_code LIKE '46P%' THEN 'Prep Course'
            ELSE subquery.edu_lac_type_nm
          END AS edu_lac_type_nm,
          subquery.state,
          subquery.lac_nm
        FROM (
          SELECT DISTINCT ON (facility_code, lac_nm)
            feed.facility_code,
            feed.edu_lac_type_nm,
            i.physical_state as state,
            feed.lac_nm
          FROM lcpe_feed_lacs feed
          JOIN institutions AS i ON i.facility_code = feed.facility_code
        ) subquery;
        CREATE INDEX ON #{table_name} (facility_code);
        CREATE INDEX ON #{table_name} (edu_lac_type_nm);
        CREATE INDEX ON #{table_name} (lac_nm);
      SQL
    end
  end
end
