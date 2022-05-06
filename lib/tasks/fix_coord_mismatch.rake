# frozen_string_literal: true

desc 'task to update any mistmached coordinates with geocoder gem.'
task fix_coord_mismatch: :environment do
  version = Version.current_preview
  results = Institution.approved_institutions(version)
  by_address = results.where(latitude: nil, longitude: nil).where.not(address_1: nil, city: nil)
  country = results.where.not(physical_country: 'USA')
  # will remove staging check, don't want it running on prod until tested
  if version.present?
    if by_address.present? && version.geocoded == false
      by_address.each do |result|
        address = parse_add(result, result.address)
        address1 = parse_add(result, result.address_1)
        address2 = parse_add(result, result.address_2)
        address3 = parse_add(result, result.address_3)
        geocode_fields(result, address, address1, address2, address3)
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
          address3 = parse_address(result, result.address_3)
          geocode_fields(result, address, address1, address2, address3)
        end
      end
    end
  end

  version.update(geocoded: true) if version.present?
end

def geocode_fields(result, address, address1, address2, address3)
  geocoded = Geocoder.coordinates(address)
  geocoded1 = Geocoder.coordinates(address1)
  geocoded2 = Geocoder.coordinates(address2)
  geocoded3 = Geocoder.coordinates(address3)
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
  stopwords = %w[ave avenue road rd dr drive blvd pkwy]
  stopwords_regex = /\b(#{Regexp.union(*stopwords).source})\b/i
  add_split = result.address.split(stopwords_regex).map(&:strip)[0..1].join(' ')
  new_address = [add_split, result.state, result.zip].compact.join(' ')
  geocoded = Geocoder.coordinates(new_address)
  # geocoded.present? ? update_mismatch(result, geocoded) : update_mismatch(result, geocoded3)
  if geocoded.present?
    update_mismatch(result, geocoded)
  else
    update_mismatch(result, geocoded3)
  end
end

def parse_add(res, address)
  if address.present?
    "#{address}, #{res.city}, #{res.state}, #{res.zip}, #{res.country}"
  else
    "#{res.city}, #{res.state}, #{res.zip}, #{res.country}"
  end
end

def parse_address(res, field)
  if field.present?
    "#{field}, #{res.city}, #{res.physical_country}"
  else
    "#{res.city}, #{res.physical_country}"
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
