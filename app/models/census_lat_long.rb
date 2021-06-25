# frozen_string_literal: true

require 'roo_helper/shared'

class CensusLatLong
  include RooHelper

  def self.export
    missing_lat_long_weams = Weam.missing_lat_long
    weams_facility_codes = missing_lat_long_weams.map { |weam| weam['facility_code'] }.uniq

    addresses = []
    Institution.missing_lat_long(Version.latest).each do |institution|
      next if weams_facility_codes.include?(institution.facility_code)

      addresses << [institution.facility_code,
                    institution.physical_address || institution.address,
                    institution.physical_city || institution.city,
                    institution.physical_state || institution.state,
                    institution.physical_zip || institution.zip]
    end

    missing_lat_long_weams.each do |weam|
      physical_address = [weam['physical_address_1'], weam['physical_address_2'], weam['physical_address_3']].compact.join(' ')
      address = [weam['address_1'], weam['address_2'], weam['address_3']].compact.join(' ')

      value = [weam['facility_code'], physical_address || address,
                    weam['physical_city'] || weam['city'],
                    weam['physical_state'] || weam['state'],
                    weam['physical_zip'] || weam['zip']]

      addresses << value if value.compact.count > 0
    end

    csvs = []
    addresses.compact.in_groups_of(10_000, false) do |batch|
      csvs << generate_csv(batch)
    end

    Group.export_csvs_as_zip(csvs, name)
  end
end
