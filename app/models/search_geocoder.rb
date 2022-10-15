# frozen_string_literal: true

class SearchGeocoder
  include ::GeocoderLogic
  attr_accessor :version, :results, :by_address, :country

  def initialize(version)
    @version = version
    # note that after successful updates, results get decremented
    @results = Institution.approved_institutions(version).where(latitude: nil, longitude: nil, no_geocode_match: false) 
    Rails.logger.info "@results size: #{@results.size}"
    @by_address = results.where(physical_country: ['USA', nil])
    Rails.logger.info "by_address size:  #{@by_address.size}"
    @country = results.where.not(physical_country: 'USA')
    Rails.logger.info "country size: #{@country.size}"
  end

  def process_geocoder_address
    by_address.each_with_index do |result, idx|
      Rails.logger.info "#{idx}: processing USA: #{result.institution} " +
        "#{result.address} #{result.address_1} #{result.address_2} " +
        "#{result.city}, #{result.state}, #{result.zip}"

      address = [parse_add_fields(result, result.address),
                 parse_add_fields(result, result.address_1),
                 parse_add_fields(result, result.address_2)]
      geocode_fields(result, address)
    end
    process_geocoder_country
  end

  def process_geocoder_country
    country.each_with_index do |result, idx|
      Rails.logger.info "#{idx}: processing #{result.country}: " + 
        "#{result.institution} #{result.address} #{result.address_1} " +
        "#{result.address_2} #{result.city}, #{result.state}, #{result.zip}"

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

  def parse_add_fields(res, field)
    string = "#{field}, #{res.city}, #{res.state}, #{res.zip}, #{res.country}"
    return string if field.present?
  end

  def parse_address(res, field)
    field.present? ? "#{field}, #{res.city}, #{res.physical_country}" : "#{res.city}, #{res.physical_country}"
  end

  def geocode_fields(result, address)
    [address[0], address[1], address[2]].each do |addy|
      geocoded = Geocoder.coordinates(addy) if addy.present?
      if geocoded.present?
        update_mismatch(result, geocoded)
        return
      end
    end

    # no geocode match on first 3 address fields. Geocode based on city, state, zip
    # then check bad address on result of geocoding
    geocoded3 = Geocoder.coordinates("#{result.city}, #{result.state}, #{result.zip}")
    check_bad_address(result, geocoded3) 
  end

  def update_mismatch(result, geocoded_coord)
    if geocoded_coord.present?
      update_institution(result, geocoded_coord[0], geocoded_coord[1])
    else
      Rails.logger.info "  No coordinates found, long/lat will not be updated, no_geocode_match will be updated to true"
      result.no_geocode_match = true
      result.save(validate: false)
    end
  end

  def update_institution(result, lat, long)
    res_lat, res_long = result.latitude, result.longitude

    msg = "updated #{result.institution} from [lat: #{res_lat}, long: #{res_long}] to [lat: #{lat}, long: #{long}]"
    Rails.logger.info msg

    result.latitude = lat
    result.longitude = long
    result.save(validate: false)
  end
end
