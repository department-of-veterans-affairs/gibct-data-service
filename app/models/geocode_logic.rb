# frozen_string_literal: true

class GeocodeLogic
  def geocode_fields(result, address, address1, address2)
    geocoded = Geocoder.coordinates(address)
    geocoded1 = Geocoder.coordinates(address1)
    geocoded2 = Geocoder.coordinates(address2)
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

  def check_bad_address(result, geocoded3)
    # uses geocoder text search and looks for coords by Institution name if applicable
    int = result.institution
    geocode_name = Geocoder.search(int.downcase.split('#').first.downcase) if int.present?
    geocode_name.present? ? full_text_search(result, geocode_name, geocoded3) : search_bad_addr(result, geocoded3)
  end

  def parse_add_fields(res, field)
    string = "#{field}, #{res.city}, #{res.state}, #{res.zip}, #{res.country}"
    return string if field.present?
  end

  def parse_address(res, field)
    field.present? ? "#{field}, #{res.city}, #{res.physical_country}" : "#{res.city}, #{res.physical_country}"
  end

  def search_bad_addr(result, geocoded3)
    # parses bad addresses and flags and issues
    stopwords = %w[ave avenue road rd dr drive blvd pkwy st street parkway]
    stopwords_regex = /\b(#{Regexp.union(*stopwords).source})\b/i
    add_split = result.address.split(stopwords_regex).map(&:strip)[0..1].join(' ')
    new_address = [add_split, result.state, result.zip].compact.join(' ')
    geocoded = Geocoder.coordinates(new_address)
    update_bad_addr(result, geocoded, geocoded3)
  end

  def update_bad_addr(result, geocoded, geocoded3)
    if geocoded.present?
      update_mismatch(result, geocoded)
    else
      update_mismatch(result, geocoded3)
      result.update(bad_address: true)
    end
  end

  def full_text_search(result, geocode_name, geocoded3)
    check_search_fields = []
    geocode_name.each do |geo|
      search_fields = check_srch_fields(result, geo)
      check_search_fields << search_fields if search_fields.present?
      next if search_fields.blank?

      upd_data = [search_fields.first.data['lat'].to_f, search_fields.first.data['lon'].to_f]
      update_mismatch(result, upd_data)
    end
    search_bad_addr(result, geocoded3) if check_search_fields.empty?
  end

  def check_srch_fields(result, geo)
    state = geo.data['address']['ISO3166-2-lvl4'].present? ? geo.data['address']['ISO3166-2-lvl4'].split('-').last : nil
    city = geo.data['address']['city']
    num = geo.data['address']['amenity'].present? ? geo.data['address']['amenity'].split(' ').last.to_i : nil
    if (num.is_a? Numeric) && (num > 1)
      return_num_text_search(result, geo, city, state, num)
    else
      return_text_search(result, geo, city, state, num)
    end
  end

  def return_num_text_search(result, geo, city, state, num)
    text_search = []
    add_num = result.institution.downcase.split('#').last.to_i
    text_search << geo if city == result.city.titleize && state == result.state && num == add_num
    text_search
  end

  def return_text_search(result, geo, city, state, _num)
    text_search = []
    zip = geo.data['address']['postcode']
    vil = geo.data['address']['village']
    city_check = result.city.titleize
    text_search << geo if city == city_check || state == result.state || zip == result.zip || vil == city_check
    text_search
  end

  def update_mismatch(result, geocoded_coord)
    if geocoded_coord.present?
      update_inst(result, geocoded_coord[0], geocoded_coord[1], result.latitude, result.longitude)
    end
  end

  def update_inst(result, lat, long, res_lat, res_long)
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
