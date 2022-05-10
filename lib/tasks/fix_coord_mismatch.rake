# frozen_string_literal: true

desc 'task to update any mistmached coordinates with geocoder gem.'
task fix_coord_mismatch: :environment do
  version = Version.current_preview
  results = Institution.approved_institutions(version)
  by_address = results.where(latitude: nil, longitude: nil).where.not(address_1: nil, city: nil)
  country = results.where.not(physical_country: 'USA')

  if version.present?
    if by_address.present?
      by_address.each do |result|
        address = parse_add_fields(result, result.address)
        address1 = parse_add_fields(result, result.address_1)
        address2 = parse_add_fields(result, result.address_2)
        geocode_fields(result, address, address1, address2)
      end
    end

    if country.present?
      country.each do |result|
        if result.state.present? && result.physical_country.present? && version.geocoded == false
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

  version.update(geocoded: true) if version.present?
end

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
  geocode_name = Geocoder.search(result.institution.downcase.split('#').first.downcase)
  if geocode_name.present?
    text_search(result, geocode_name)
  else
    search_bad_addr(result, geocoded3)
  end
end

def parse_add_fields(res, field)
  field.nil? ? nil : "#{field}, #{res.city}, #{res.state}, #{res.zip}, #{res.country}"
end

def parse_address(res, field)
  if field.present?
    "#{field}, #{res.city}, #{res.physical_country}"
  else
    "#{res.city}, #{res.physical_country}"
  end
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

def text_search(result, geocode_name)
  geocode_name.each do |geo|
    next if ck_srch_fields(result, geo).blank?

    upd_data = [ck_srch_fields(result, geo).first.data['lat'].to_f, ck_srch_fields(result, geo).first.data['lon'].to_f]
    update_mismatch(result, upd_data)
  end
end

def ck_srch_fields(result, geo)
  state = geo.data['address']['ISO3166-2-lvl4'].present? ? geo.data['address']['ISO3166-2-lvl4'].split('-').last : nil
  city = geo.data['address']['city']
  zip = geo.data['address']['postcode']
  num = geo.data['address']['amenity'].present? ? geo.data['address']['amenity'].split(' ').last.to_i : nil
  if (num.is_a? Numeric) && (num > 1)
    return_num_text_search(result, geo, city, state, num)
  else
    return_text_search(result, geo, city, state, zip)
  end
end

def return_num_text_search(result, geo, city, state, num)
  text_search = []
  add_num = result.institution.downcase.split('#').last.to_i
  text_search << geo if city == result.city.titleize && state == result.state && num == add_num
end

def return_text_search(result, geo, city, state, zip)
  text_search = []
  vil = geo.data['address']['village']
  if city == result.city.titleize || state == result.state || zip == result.zip || vil == result.city.titleize
    text_search << geo
  end
end

def update_mismatch(result, geocoded_coord)
  if geocoded_coord.present?
    lat = geocoded_coord[0]
    long = geocoded_coord[1]
    int = result.institution
    if result.latitude.present? && result.longitude.present?
      if lat.round(2) != result.latitude.round(2) || long.round(2) != result.longitude.round(2)
        puts "updated #{int} from [lat: #{result.latitude}, long: #{result.longitude}] to [lat: #{lat}, long: #{long}]"
        result.latitude = lat
        result.longitude = long
        result.save(validate: false)
      end
    else
      puts "updated #{int} from [lat: #{result.latitude}, long: #{result.longitude}] to [lat: #{lat}, long: #{long}]"
      result.latitude = lat
      result.longitude = long
      result.save(validate: false)
    end
  end
end
