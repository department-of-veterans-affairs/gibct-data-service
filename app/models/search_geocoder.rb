# frozen_string_literal: true

class SearchGeocoder < GeocodeLogic
  attr_accessor :results, :by_address, :country

  def initialize(version)
    @results = Institution.approved_institutions(version)
    @by_address = results.where(latitude: nil, longitude: nil).where.not(address_1: nil, city: nil)
    @country = results.where.not(physical_country: 'USA')
  end

  def process_geocoder_address
    by_address.each do |result|
      address = parse_add_fields(result, result.address)
      address1 = parse_add_fields(result, result.address_1)
      address2 = parse_add_fields(result, result.address_2)
      geocode_fields(result, address, address1, address2)
    end
  end

  def process_geocoder_country
    country.each do |result|
      if result.state.present? && result.physical_country.present?
        geocoded_ct = Geocoder.coordinates(result.physical_country)
        update_mismatch(result, geocoded_ct)
      else
        address = parse_address(result, result.address)
        address1 = parse_address(result, result.address_1)
        address2 = parse_address(result, result.address_2)
        geocode_fields(result, address, address1, address2)
      end
    end
  end
end
