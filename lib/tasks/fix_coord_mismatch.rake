# frozen_string_literal: true

desc 'task to update any mistmached coordinates with geocoder gem.'
task fix_coord_mismatch: :environment do
  version = Version.current_preview
  results = Institution.approved_institutions(version)
  by_address = results.select { |r| r.address.present? && r.city.present? }
  country = results.reject { |r| r.physical_country == 'USA' }
  # will remove staging check, don't want it running on prod until tested
  if version.present? && staging?
    if by_address.present? && version.geocoded == false
      by_address.each do |result|
        address = parse_add(result, result.address)
        address2 = parse_add(result, result.address_2)
        address3 = parse_add(result, result.address_3)
        geocode_fields(result, address, address2, address3)
      end
    end

    if country.present?
      country.each do |result|
        if result.state.present? && result.physical_country.present? && version.geocoded == false
          geocoded_ct = Geocoder.coordinates(result.physical_country)
          update_mismatch(result, geocoded_ct)
        else
          address = parse_address(result, result.address)
          address2 = parse_address(result, result.address_2)
          address3 = parse_address(result, result.address_3)
          geocode_fields(result, address, address2, address3)
        end
      end
    end
  end

  version.update(geocoded: true) if version.present?
end

def geocode_fields(result, address, address2, address3)
  geocoded = Geocoder.coordinates(address)
  geocoded2 = Geocoder.coordinates(address2)
  geocoded3 = Geocoder.coordinates(address3)
  if geocoded.present?
    update_mismatch(result, geocoded)
  elsif geocoded2.present?
    update_mismatch(result, geocoded2)
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
