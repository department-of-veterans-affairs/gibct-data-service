# frozen_string_literal: true

class CrosswalkIssue < ApplicationRecord
  include RooHelper::Shared

  PARTIAL_MATCH_TYPE = 'PARTIAL_MATCH_TYPE'
  IPEDS_ORPHAN_TYPE = 'IPEDS_ORPHAN_TYPE'

  belongs_to :crosswalk, optional: true
  belongs_to :ipeds_hd, optional: true
  belongs_to :weam, optional: true

  validate :at_least_one_parent_is_set

  scope :by_issue_type, ->(n) { where(issue_type: n) }

  # class methods
  def self.partials
    includes(:crosswalk, :ipeds_hd, weam: :arf_gi_bill)
      .by_issue_type(CrosswalkIssue::PARTIAL_MATCH_TYPE)
      .order('arf_gi_bills.gibill desc nulls last, weams.institution, weams.facility_code')
  end

  def self.orphans
    # case statement is from most common to least common
    joins('INNER JOIN ipeds_hds ON ipeds_hds.id = crosswalk_issues.ipeds_hd_id ' \
      'LEFT JOIN weams ope_join ON ope_join.ope = ipeds_hds.ope ' \
      'LEFT JOIN weams crs_join ON crs_join.cross = ipeds_hds.cross')
      .select(
        'ipeds_hds.institution, ' \
        'ipeds_hds.addr as addr, ' \
        'ipeds_hds.city as city, ' \
        'ipeds_hds.state as state, ' \
        'ipeds_hds.zip as zip, ' \
        'ipeds_hds.cross as ipeds, ' \
        'ipeds_hds.ope as ope, ' \
        'coalesce(crs_join.facility_code, ope_join.facility_code) as facility_code, ' \
        'case when crs_join.facility_code is null and ope_join.facility_code is null then null ' \
        'when crs_join.facility_code is not null and ope_join.facility_code is not null then \'IPEDS & OPE\' ' \
        'when crs_join.facility_code is not null and ope_join.facility_code is null then \'IPEDS\' ' \
        'else \'OPE\' end as match_type'
      )
      .by_issue_type(CrosswalkIssue::IPEDS_ORPHAN_TYPE)
      .order('ipeds_hds.institution')
  end

  def self.export_and_pluck_partials
    partials.pluck(
      'arf_gi_bills.gibill', 'weams.institution', 'weams.facility_code', 'weams.cross',
      'weams.ope', 'ipeds_hds.cross', 'ipeds_hds.ope', 'crosswalks.cross', 'crosswalks.ope'
    )
  end

  # For orphans, we're creating crosswalk_issue rows where there's no
  # crosswalk row for ipeds_hd. We try to match using ope and cross
  # (ipeds). It also seems to be the case that in these circumstances,
  # there's no weams row either.
  # rubocop:disable Metrics/MethodLength
  def self.rebuild
    sql = <<-SQL
      INSERT INTO crosswalk_issues (
        weam_id, crosswalk_id, ipeds_hd_id, issue_type
      )
      SELECT
        weams.id, crosswalks.id, ipeds_hds.id, '#{PARTIAL_MATCH_TYPE}'
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
          LEFT OUTER JOIN ipeds_hds ON ipeds_hds.id = ipeds_hd_id
          LEFT OUTER JOIN crosswalks ON crosswalks.id = crosswalk_id
          INNER JOIN ignored_crosswalk_issues
            ON weams.facility_code = ignored_crosswalk_issues.facility_code
            AND (
              (ipeds_hds.cross IS NOT DISTINCT FROM ignored_crosswalk_issues.cross
                AND ipeds_hds.ope IS NOT DISTINCT FROM ignored_crosswalk_issues.ope)
              OR (crosswalks.cross IS NOT DISTINCT FROM ignored_crosswalk_issues.cross
                AND crosswalks.ope IS NOT DISTINCT FROM ignored_crosswalk_issues.ope)
            )
      );
    SQL

    InstitutionProgram.connection.execute(sql)
  end
  # rubocop:enable Metrics/MethodLength

  # instance methods
  def resolved?
    weam_ipeds_hd_match? && weam_crosswalk_match?
  end

  private

  def weam_ipeds_hd_match?
    weam.present? && ipeds_hd.present? &&
      weam.cross == ipeds_hd.cross && weam.ope == ipeds_hd.ope
  end

  def weam_crosswalk_match?
    weam.present? && crosswalk.present? &&
      weam.cross == crosswalk.cross && weam.ope == crosswalk.ope
  end

  def at_least_one_parent_is_set
    return if weam_id.present? || ipeds_hd_id.present? || crosswalk_id.present?

    errors.add :base, :invalid, message: 'At least one weam or iped or crosswalk must be set'
  end
end
