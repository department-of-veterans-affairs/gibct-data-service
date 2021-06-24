# frozen_string_literal: true

require 'roo_helper/shared'

class CensusLatLong
  include RooHelper

  def export
    version = Version.latest
    missing_lat_long_institutions = Institution.approved_institutions(version).where.not(latitude: null, longitude: null)

    sql = <<-SQL
      SELECT weams.*
			FROM weams
			LEFT OUTER JOIN ipeds_hds ON weams.cross = ipeds_hds.cross
			LEFT OUTER JOIN scorecards ON weams.cross = scorecards.cross
			WHERE
			(ipeds_hds.cross IS NULL AND scorecards.cross IS NULL) OR
			(ipeds_hds.cross IS NOT NULL AND (UPPER(ipeds_hds.city) != UPPER(weams.physical_city) OR UPPER(ipeds_hds.state) != UPPER(weams.physical_state) OR UPPER(weams.institution) != UPPER(ipeds_hds.institution))) OR
			(scorecards.cross IS NOT NULL AND (UPPER(scorecards.city) != UPPER(weams.physical_city) OR UPPER(scorecards.state) != UPPER(weams.physical_state)))
      AND weams.approved IS TRUE
    SQL

    missing_lat_long_weams = Weam.connection.select(sql)
    weams_facility_codes = missing_lat_long_weams.map{|weam| weam.facility_code}

    address = []
    missing_lat_long_institutions.each do |institution|
      next if
    end
  end
end
