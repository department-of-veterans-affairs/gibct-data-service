# frozen_string_literal: true

require 'roo_helper/shared'

class CensusLatLong
  include RooHelper

  def self.export
    missing_lat_long_weams = Weam.missing_lat_long
    weams_facility_codes = missing_lat_long_weams.map(&:facility_code).uniq

    addresses = []
    Institution.missing_lat_long(Version.latest).each do |institution|
      next if weams_facility_codes.includes(institution.facility_code)

      addresses << [institution.facility_code, institution.physical_address, institution.physical_city, institution.physical_state, institution.physical_zip ]
    end

    missing_lat_long_weams.each do |weam|
      addresses << [weam.facility_code, weam.physical_address, weam.physical_city, weam.physical_state, weam.physical_zip ]
    end

    csvs = []
    addresses.in_groups_of(10000) do |batch|
      csvs << generate_csv(batch)
    end

    Group.export_csvs_as_zip(csvs, self)
  end
end
