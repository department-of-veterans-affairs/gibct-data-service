# frozen_string_literal: true

class CrosswalkIssue < ApplicationRecord
  WEAMS_SOURCE = 'weams'
  IPEDS_HDS_SOURCE = 'ipeds'

  belongs_to :crosswalk
  belongs_to :ipeds_hd
  belongs_to :weam

  # rubocop:disable Metrics/MethodLength
  def self.rebuild
    CrosswalkIssue.delete_all

    sql = <<-SQL
      INSERT INTO crosswalk_issues (
        weam_id,
        crosswalk_id,
        ipeds_hd_id,
        source
      )
      SELECT
        weams.id,
        crosswalks.id,
        ipeds_hds.id,
        '#{WEAMS_SOURCE}'
      FROM weams
        LEFT OUTER JOIN ipeds_hds ON (weams.cross = ipeds_hds.cross)
          OR (weams.ope = ipeds_hds.ope)
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
        AND NOT(weams.campus_type IS NOT NULL AND UPPER(weams.campus_type) = 'E')
      UNION
      SELECT
        NULL,
        crosswalks.id,
        ipeds_hds.id,
        '#{IPEDS_HDS_SOURCE}'
      FROM ipeds_hds
        LEFT OUTER JOIN crosswalks ON ipeds_hds.cross = crosswalks.cross OR ipeds_hds.ope = crosswalks.ope
      WHERE crosswalks.ID IS NULL
    SQL

    InstitutionProgram.connection.execute(sql)
  end
  # rubocop:enable Metrics/MethodLength

  scope :issue_source, ->(n) { where(source: n) }
end
