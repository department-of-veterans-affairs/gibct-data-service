# frozen_string_literal: true

class CensusLatLong < ImportableRecord
  CSV_CONVERTER_INFO = {
    'facility_code' => { column: :facility_code, converter: BaseConverter },
    'input_address' => { column: :input_address, converter: BaseConverter },
    'tiger_address_range_match_indicator' => { column: :tiger_address_range_match_indicator, converter: BaseConverter },
    'tiger_match_type' => { column: :tiger_match_type, converter: BaseConverter },
    'tiger_output_address' => { column: :tiger_output_address, converter: BaseConverter },
    'interpolated_longitude_latitude' => { column: :interpolated_longitude_latitude, converter: BaseConverter },
    'tiger_line_id' => { column: :tiger_line_id, converter: BaseConverter },
    'tiger_line_id_side' => { column: :tiger_line_id_side, converter: BaseConverter }
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
end
