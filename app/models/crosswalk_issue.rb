# frozen_string_literal: true

class CrosswalkIssue < ApplicationRecord
  belongs_to :crosswalk
  belongs_to :ipeds_hd
  belongs_to :weam

  def institution_name
    weam.nil? ? nil : weam.institution
  end

  def facility_code
    weam.nil? ? nil : weam.facility_code
  end

  def weams_ipeds
    weam.nil? ? nil : weam.cross
  end

  def weams_ope
    weam.nil? ? nil : weam.ope
  end

  def ipeds_hd_ipeds
    ipeds_hd.nil? ? nil : ipeds_hd.cross
  end

  def ipeds_hd_ope
    ipeds_hd.nil? ? nil : ipeds_hd.ope
  end

  def crosswalk_ipeds
    crosswalk.nil? ? nil : crosswalk.cross
  end

  def crosswalk_ope
    crosswalk.nil? ? nil : crosswalk.ope
  end

  # rubocop:disable Metrics/MethodLength
  def self.build
    CrosswalkIssue.delete_all

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
        LEFT OUTER JOIN ipeds_hds ON weams.institution = ipeds_hds.institution
          OR (weams.cross = ipeds_hds.cross AND weams.cross IS NOT NULL)
          OR (weams.ope = ipeds_hds.ope AND weams.ope IS NOT NULL)
        LEFT OUTER JOIN crosswalks ON weams.facility_code = crosswalks.facility_code
      WHERE
        (institution_of_higher_learning_indicator = true OR non_college_degree_indicator = true)
        AND NOT(
          weams.cross = ipeds_hds.cross
          AND weams.cross = crosswalks.cross
          AND weams.cross IS NOT NULL
          AND ipeds_hds.cross IS NOT NULL
          AND crosswalks.cross IS NOT NULL
        )
        AND NOT(
          weams.cross IS NULL
          AND weams.ope IS NULL
          AND ipeds_hds.cross IS NULL
          AND ipeds_hds.ope IS NULL
          AND crosswalks.cross IS NULL
          AND crosswalks.ope IS NULL
        )
        AND UPPER(weams.campus_type) != 'E'
      ORDER BY weams.institution
    SQL

    InstitutionProgram.connection.execute(sql)
  end
  # rubocop:enable Metrics/MethodLength
end
