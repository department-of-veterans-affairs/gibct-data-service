# frozen_string_literal: true

class SearchGeocoder
  include ::GeocoderLogic
  attr_accessor :results, :by_address, :country

  def initialize(version)
    @results = Institution.approved_institutions(version)
    @by_address = results.where(latitude: nil, longitude: nil).where.not(address_1: nil, city: nil)
    @country = results.where.not(physical_country: 'USA')
  end

  def process_geocoder_address
    by_address.each do |result|
      address = [parse_add_fields(result, result.address),
                 parse_add_fields(result, result.address_1),
                 parse_add_fields(result, result.address_2)]
      geocode_fields(result, address)
    end
  end

  def process_geocoder_country
    country.each do |result|
      if result.state.present? && result.physical_country.present?
        geocoded_ct = Geocoder.coordinates(result.physical_country)
        update_mismatch(result, geocoded_ct)
      else
        address = [parse_address(result, result.address),
                   parse_address(result, result.address_1),
                   parse_address(result, result.address_2)]
        geocode_fields(result, address)
      end
    end
  end

  private

  def parse_add_fields(res, field)
    string = "#{field}, #{res.city}, #{res.state}, #{res.zip}, #{res.country}"
    return string if field.present?
  end

  def parse_address(res, field)
    field.present? ? "#{field}, #{res.city}, #{res.physical_country}" : "#{res.city}, #{res.physical_country}"
  end

  def geocode_fields(result, address)
    geocoded = Geocoder.coordinates(address[0])
    geocoded1 = Geocoder.coordinates(address[1])
    geocoded2 = Geocoder.coordinates(address[2])
    geocoded3 = Geocoder.coordinates("#{result.city}, #{result.state}, #{result.zip}")
    if geocoded.present?
      update_mismatch(result, geocoded)
    elsif geocoded1.present?
      update_mismatch(result, geocoded1)
    elsif geocoded2.present?
      update_mismatch(result, geocoded2)
    else
      check_bad_address(result, geocoded3)
    end
  end

  def update_mismatch(result, geocoded_coord)
    if geocoded_coord.present?
      update_institution(result, geocoded_coord[0], geocoded_coord[1], result.latitude, result.longitude)
    end
  end

  def update_institution(result, lat, long, res_lat, res_long)
    if res_lat.present? && res_long.present?
      if lat.round(2) != res_lat.round(2) || long.round(2) != res_long.round(2)
        msg = "updated #{result.institution} from [lat: #{res_lat}, long: #{res_long}] to [lat: #{lat}, long: #{long}]"
        Rails.logger.info msg
        result.latitude = lat
        result.longitude = long
        result.save(validate: false)
      end
    else
      msg = "updated #{result.institution} from [lat: #{res_lat}, long: #{res_long}] to [lat: #{lat}, long: #{long}]"
      Rails.logger.info msg
      result.latitude = lat
      result.longitude = long
      result.save(validate: false)
    end
  end
end
