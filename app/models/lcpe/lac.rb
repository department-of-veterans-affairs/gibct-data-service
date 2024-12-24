# frozen_string_literal: true

module Lcpe
  class Lac < ApplicationRecord
    extend Edm::SqlContext

    has_many :lac_tests

    belongs_to(
      :institution,
      foreign_key: :facility_code,
      primary_key: :facility_code)

    belongs_to(
      :weam,
      foreign_key: :facility_code,
      primary_key: :facility_code)

    def self.rebuild
      pure_sql(<<~SQL)
        INSERT INTO #{table_name} (id, facility_code, edu_lac_type_nm, lac_nm)
        SELECT
          ROW_NUMBER() OVER () AS id,
          facility_code,
          CASE
            WHEN facility_code LIKE '46P%' THEN 'Prep Course'
            ELSE edu_lac_type_nm
          END AS edu_lac_type_nm,
          lac_nm
        FROM (
          SELECT DISTINCT ON (facility_code, lac_nm)
            facility_code,
            edu_lac_type_nm,
            lac_nm
          FROM lcpe_feed_lacs
        ) subquery;
        CREATE INDEX ON #{table_name} (facility_code);
        CREATE INDEX ON #{table_name} (edu_lac_type_nm);
        CREATE INDEX ON #{table_name} (lac_nm);
      SQL
    end

    def self.reset
      pure_sql
        .join(drop_indices)
        .join(truncate_table)
        .join(rebuild)
        .execute
    end
  end
end
