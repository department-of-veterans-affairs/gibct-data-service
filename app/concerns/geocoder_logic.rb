# frozen_string_literal: true

module GeocoderLogic
  private

  def check_bad_address(result, geocoded3)
    # uses geocoder text search and looks for coords by Institution name if applicable
    inst = result.institution
    geocode_name, timed_out = geocode_addy('search', inst.downcase.split('#').first, 0) if inst.present?
    return if timed_out

    geocode_name.present? ? full_text_search(result, geocode_name, geocoded3) : search_bad_address(result, geocoded3)
  end

  def search_bad_address(result, geocoded3)
    # parses bad addresses and flags and issues
    stopwords = %w[ave avenue road rd dr drive blvd pkwy st street parkway]
    stopwords_regex = /\b(#{Regexp.union(*stopwords).source})\b/i
    if result.address
      add_split = result.address.split(stopwords_regex).map(&:strip)[0..1].join(' ')
      new_address = [add_split, result.state, result.zip].compact.join(' ')
    end

    geocoded, timed_out = geocode_addy('coordinates', new_address, 0)
    return if timed_out

    update_bad_address(result, geocoded, geocoded3)
  end

  def update_bad_address(result, geocoded, geocoded3)
    if geocoded.present?
      update_mismatch(result, geocoded)
    else
      update_mismatch(result, geocoded3)
    end
    result.update(bad_address: true) if result.country == 'USA' || result.physical_country == 'USA'
  end

  def full_text_search(result, geocode_name, geocoded3)
    check_search = []
    geocode_name.each do |geocoder_fields|
      search_fields = check_search_fields(result, geocoder_fields)
      check_search << search_fields if search_fields.present?
      next if search_fields.blank?

      upd_data = [search_fields[0].data.dig('lat').to_f, search_fields[0].data.dig('lon').to_f]
      update_mismatch(result, upd_data)
    end
    search_bad_address(result, geocoded3) if check_search.empty?
  end

  def check_search_fields(result, geo)
    geocoder_state = geo.data.dig('address', 'ISO3166-2-lvl4')
    geocoder_address_number = geo.data.dig('address', 'amenity')
    state = geocoder_state.present? ? geocoder_state.split('-').last : nil
    city = geo.data.dig('address', 'city')
    num = geocoder_address_number.present? ? geocoder_address_number.split(' ').last.to_i : nil
    if (num.is_a? Numeric) && (num > 1)
      text_search_numbered_address(result, geo, city, state, num)
    else
      text_search(result, geo, city, state)
    end
  end

  def text_search_numbered_address(result, geo, city, state, num)
    search = []
    address_number = result.institution.downcase.split('#').last.to_i
    titleized_city = result.city ? result.city.titleize : ''
    search << geo if city == titleized_city && state == result.state && num == address_number
    search
  end

  def text_search(result, geo, city, state)
    search = []
    zip = geo.data.dig('address', 'postcode')
    village = geo.data.dig('address', 'village')
    city_check = result.city.titleize if result.city
    search << geo if city == city_check || state == result.state || zip == result.zip || village == city_check
    search
  end

  def geocode_addy(geocode_type, data, retry_count = 0)
    return [nil, true] if retry_count > 3

    begin
      # We added this line so that RSpec and SimpleCov will test and show coverage for
      # Exceptions the Geocoder gem raises. Not elegant but it does prove the exception
      # handling logic works correctly. See "describe 'exception handling'" in the spec.
      throw_geocode_exception(data) if geocode_type.eql?('exception_test')

      timed_out = false
      geocoded = Geocoder.send geocode_type.to_sym, data
    rescue Timeout::Error
      Rails.logger.info "  Geocode.#{geocode_type} timed out with #{data} retrying"
      geocoded, timed_out = geocode_addy(geocode_type, data, retry_count + 1)
    rescue SocketError
      Rails.logger.info "  Geocode.#{geocode_type} socket error with #{data} retrying"
      geocoded, timed_out = geocode_addy(geocode_type, data, retry_count + 1)
    rescue Geocoder::OverQueryLimitError
      Rails.logger.info "  Geocode.#{geocode_type} query limit error with #{data} retrying"
      geocoded, timed_out = geocode_addy(geocode_type, data, retry_count + 1)
    rescue Geocoder::RequestDenied
      Rails.logger.info "  Geocode.#{geocode_type} request denied with #{data} retrying"
      geocoded, timed_out = geocode_addy(geocode_type, data, retry_count + 1)
    rescue Geocoder::InvalidRequest
      Rails.logger.info "  Geocode.#{geocode_type} request invalid with #{data} retrying"
      geocoded, timed_out = geocode_addy(geocode_type, data, retry_count + 1)
    rescue Geocoder::InvalidApiKey
      Rails.logger.info "  Geocode.#{geocode_type} API key invalid with #{data} retrying"
      geocoded, timed_out = geocode_addy(geocode_type, data, retry_count + 1)
    rescue Geocoder::ServiceUnavailable
      Rails.logger.info "  Geocode.#{geocode_type} service unavailable with #{data} retrying"
      geocoded, timed_out = geocode_addy(geocode_type, data, retry_count + 1)
    rescue Geocoder::NetworkError
      Rails.logger.info "  Geocode.#{geocode_type} network error with #{data} retrying"
      geocoded, timed_out = geocode_addy(geocode_type, data, retry_count + 1)
    rescue Geocoder::ResponseParseError
      Rails.logger.info "  Geocode.#{geocode_type} response parse error with #{data} retrying"
      @parse_error_count += 1
      Rails.logger.info "  Parse error count: #{@parse_error_count}"
      geocoded, timed_out = geocode_addy(geocode_type, data, retry_count + 1)
    end

    [geocoded, timed_out]
  end

  def throw_geocode_exception(exception_type)
    exception_type = exception_type.new(nil) if
      Rails.env.eql?('test') && exception_type.eql?(Geocoder::ResponseParseError)

    raise exception_type
  end
end
