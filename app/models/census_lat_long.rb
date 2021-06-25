# frozen_string_literal: true

require 'roo_helper/shared'

class CensusLatLong
  include RooHelper

  # Create CSVs for:
  #
  # - Institutions rows from latest version that do not have a latitude or longitude
  # - Weams rows who either do not have an ipeds_hd or scorecard
  def self.export
    missing_lat_long_physical_weams = Weam.missing_lat_long_physical
    missing_lat_long_mailing_weams = Weam.missing_lat_long_mailing

    weams_physical_facility_codes = missing_lat_long_physical_weams.map { |weam| weam['facility_code'] }.uniq
    weams_mailing_facility_codes = missing_lat_long_mailing_weams.map { |weam| weam['facility_code'] }.uniq
    weams_facility_codes = weams_physical_facility_codes + weams_mailing_facility_codes.uniq

    addresses = []
    Institution.missing_lat_long(Version.latest).each do |institution|
      next if weams_facility_codes.include?(institution.facility_code)

      addresses << [institution.facility_code,
                    institution.physical_address || institution.address,
                    institution.physical_city || institution.city,
                    institution.physical_state || institution.state,
                    institution.physical_zip || institution.zip]
    end

    missing_lat_long_physical_weams.each do |weam|
      physical_address = [weam['physical_address_1'], weam['physical_address_2'], weam['physical_address_3']].compact.join(' ')

      value = [weam['facility_code'], physical_address,
                    weam['physical_city'],
                    weam['physical_state'],
                    weam['physical_zip']]

      addresses << value if value.compact.count > 0
    end

    missing_lat_long_mailing_weams.each do |weam|
      next if weams_physical_facility_codes.include?(weam['facility_code'])
      address = [weam['address_1'], weam['address_2'], weam['address_3']].compact.join(' ')

      value = [weam['facility_code'], address,
                    weam['city'],
                    weam['state'],
                    weam['zip']]

      addresses << value if value.compact.count > 0
    end

    csvs = []
    addresses.compact.in_groups_of(10_000, false) do |batch|
      csvs << generate_csv(batch)
    end

    Group.export_csvs_as_zip(csvs, name)
  end
end
