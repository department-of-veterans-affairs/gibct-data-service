# frozen_string_literal: true

module GeocoderLogic
  private

  def check_bad_address(result, geocoded3)
    # uses geocoder text search and looks for coords by Institution name if applicable
    inst = result.institution
    geocode_name = Geocoder.search(inst.downcase.split('#').first) if inst.present?
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
    geocoded = Geocoder.coordinates(new_address)
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
end
