# frozen_string_literal: true

class CrosswalkIssue < ApplicationRecord
  belongs_to :crosswalk
  belongs_to :ipeds_hd
  belongs_to :weam

  # rubocop:disable Metrics/MethodLength
  def self.rebuild
    sql = <<-SQL
      INSERT INTO crosswalk_issues (
        weam_id,
        crosswalk_id,
        ipeds_hd_id
      )
      SELECT
        weams.id,
        crosswalks.id,
        ipeds_hds.id
      FROM weams
        LEFT OUTER JOIN ipeds_hds ON  weams.cross = ipeds_hds.cross
          OR weams.ope = ipeds_hds.ope
        LEFT OUTER JOIN crosswalks ON weams.facility_code = crosswalks.facility_code
      WHERE
        (institution_of_higher_learning_indicator = true OR non_college_degree_indicator = true)
        AND NOT(
          weams.cross IS NOT NULL
          AND ipeds_hds.cross IS NOT NULL
          AND crosswalks.cross IS NOT NULL
          AND weams.cross = ipeds_hds.cross
          AND weams.cross = crosswalks.cross
        )
        AND NOT(
          weams.cross IS NULL
          AND weams.ope IS NULL
          AND ipeds_hds.ope IS NULL
          AND crosswalks.cross IS NULL
          AND crosswalks.ope IS NULL
        )
        AND UPPER(weams.campus_type) is distinct from 'E'
    SQL

    InstitutionProgram.connection.execute(sql)
  end
  # rubocop:enable Metrics/MethodLength
end
