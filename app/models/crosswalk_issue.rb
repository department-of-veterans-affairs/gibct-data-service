# frozen_string_literal: true

class CrosswalkIssue < ApplicationRecord
  PARTIAL_MATCH_TYPE = 'PARTIAL_MATCH_TYPE'
  IPEDS_ORPHAN_TYPE = 'IPEDS_ORPHAN_TYPE'

  belongs_to :crosswalk
  belongs_to :ipeds_hd
  belongs_to :weam

  scope :by_issue_type, ->(n) { where(issue_type: n) }

  def resolved?
    weam_ipeds_hd_match? && weam_crosswalk_match?
  end

  # rubocop:disable Metrics/MethodLength
  def self.rebuild
    sql = <<-SQL
      INSERT INTO crosswalk_issues (
        weam_id,
        crosswalk_id,
        ipeds_hd_id,
        issue_type
      )
      SELECT
        weams.id,
        crosswalks.id,
        ipeds_hds.id,
        '#{PARTIAL_MATCH_TYPE}'
      FROM weams
        LEFT OUTER JOIN ipeds_hds ON  weams.cross = ipeds_hds.cross
          OR weams.ope = ipeds_hds.ope
        LEFT OUTER JOIN crosswalks ON weams.facility_code = crosswalks.facility_code
      WHERE
        (institution_of_higher_learning_indicator = true OR non_college_degree_indicator = true)
        AND LOWER(poo_status) = 'aprvd'
        AND LENGTH(applicable_law_code) > 0
        AND LOWER(applicable_law_code) != 'educational institution is not approved'
        AND LOWER(applicable_law_code) != 'educational institution is approved for chapter 31 only'
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
      UNION
      SELECT
        NULL,
        crosswalks.id,
        ipeds_hds.id,
        '#{IPEDS_ORPHAN_TYPE}'
      FROM ipeds_hds
        LEFT OUTER JOIN crosswalks ON ipeds_hds.cross = crosswalks.cross OR ipeds_hds.ope = crosswalks.ope
      WHERE crosswalks.ID IS NULL;

      DELETE
      FROM crosswalk_issues
      WHERE id IN(
        SELECT crosswalk_issues.id FROM crosswalk_issues
          INNER JOIN weams on weams.id = weam_id
          LEFT OUTER JOIN ipeds_hds on ipeds_hds.id = ipeds_hd_id
          LEFT OUTER JOIN crosswalks ON crosswalks.id = crosswalk_id
          INNER JOIN ignored_crosswalk_issues
            ON weams.facility_code = ignored_crosswalk_issues.facility_code
            AND (ipeds_hds.cross = ignored_crosswalk_issues.cross OR crosswalks.cross = ignored_crosswalk_issues.cross)
      );
    SQL

    InstitutionProgram.connection.execute(sql)
  end
  # rubocop:enable Metrics/MethodLength

  private

  def weam_ipeds_hd_match?
    weam.present? && ipeds_hd.present? &&
      weam.cross == ipeds_hd.cross && weam.ope == ipeds_hd.ope
  end

  def weam_crosswalk_match?
    weam.present? && crosswalk.present? &&
      weam.cross == crosswalk.cross && weam.ope == crosswalk.ope
  end
end
