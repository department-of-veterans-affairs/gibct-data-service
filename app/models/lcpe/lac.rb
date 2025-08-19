# frozen_string_literal: true

module Lcpe
  class Lac < ApplicationRecord
    extend SqlContext

    # using Enriched IDs is a good way to ensure that
    # a stale ID preloaded from the browser is not used.
    # :nocov:
    scope :with_enriched_id, lambda {
      preload_id = Lcpe::PreloadDataset.fresh(klass.to_s).id
      select(
        '*',
        "CONCAT(id, 'v', #{preload_id}) enriched_id"
      )
    }

    scope :by_enriched_id, lambda { |enriched_id|
      id = enriched_id.split('v').first

        with(enriched_query: with_enriched_id.where('id = ?', id))
          .select("#{table_name}.*", 'enriched_query.enriched_id')
          .from(table_name.to_s)
          .joins("LEFT JOIN enriched_query ON #{table_name}.id = enriched_query.id")
          .where('enriched_query.enriched_id = ?', enriched_id)
    }
    # :nocov:

    has_many :tests, class_name: 'LacTest', dependent: :destroy

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
