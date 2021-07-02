# frozen_string_literal: true

class CensusLatLong < ImportableRecord
  CSV_CONVERTER_INFO = {
    'record_id_number' => { column: :facility_code, converter: FacilityCodeConverter }
  }.freeze

  # Creates a ZIP file of CSVs by combining results from
  #  - add_institution_addresses
  #  - add_weams_physical_addresses
  #  - add_weams_mailing_addresses
  def self.export
    missing_lat_long_physical_weams = Weam.missing_lat_long_physical
    missing_lat_long_mailing_weams = Weam.missing_lat_long_mailing

    weams_physical_facility_codes = missing_lat_long_physical_weams.map(&:facility_code).uniq
    weams_mailing_facility_codes = missing_lat_long_mailing_weams.map(&:facility_code).uniq
    weams_facility_codes = weams_physical_facility_codes + weams_mailing_facility_codes.uniq

    addresses = []
    add_institution_addresses(addresses, weams_facility_codes)
    add_weams_physical_addresses(addresses, missing_lat_long_physical_weams)
    add_weams_mailing_addresses(addresses, missing_lat_long_mailing_weams, weams_physical_facility_codes)

    csvs = []
    addresses.compact.in_groups_of(10_000, false) do |batch|
      csvs << generate_csv(batch)
    end

    Group.export_csvs_as_zip(csvs, name)
  end

  # Adds Approved Institutions rows from latest version that do not have a latitude or longitude
  #   - if the facility code is present in weams_facility_codes it is ignored
  def self.add_institution_addresses(addresses, weams_facility_codes)
    Institution.missing_lat_long(Version.latest).each do |institution|
      next if weams_facility_codes.include?(institution.facility_code)

      physical_value = [institution.physical_address, institution.physical_city, institution.physical_state,
                        institution.physical_zip]

      mailing_value = [institution.address, institution.city, institution.state, institution.zip]

      if physical_value.compact.count.positive?
        addresses << physical_value.unshift(institution.facility_code)
      elsif mailing_value.compact.count.positive?
        addresses << mailing_value.unshift(institution.facility_code)
      end
    end
  end

  # Adds Approved Weams rows with physical city and physical state that meets one of these conditions:
  #   - does not have an ipeds_hd or scorecard
  #   - has ipeds_hd row but either physical city, physical state, or institution name does not match
  #   - has scorecard row but either physical city, or physical state does not match
  def self.add_weams_physical_addresses(addresses, missing_lat_long_physical_weams)
    missing_lat_long_physical_weams.each do |weam|
      value = [weam.physical_address,
               weam.physical_city,
               weam.physical_state,
               weam.physical_zip]

      addresses << value.unshift(weam.facility_code) if value.compact.count.positive?
    end
  end

  # Adds Approved Weams rows without physical city and physical state that meets one of these conditions:
  #   - has ipeds_hd row but either city, or state does not match
  #   - has scorecard row but either city, or state does not match
  #   - if the facility code is present in missing_lat_long_physical_weams it is ignored
  def self.add_weams_mailing_addresses(addresses, missing_lat_long_mailing_weams, weams_physical_facility_codes)
    missing_lat_long_mailing_weams.each do |weam|
      next if weams_physical_facility_codes.include?(weam.facility_code)

      value = [weam.address,
               weam.city,
               weam.state,
               weam.zip]

      addresses << value.unshift(weam.facility_code) if value.compact.count.positive?
    end
  end
end
