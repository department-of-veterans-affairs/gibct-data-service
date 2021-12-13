# frozen_string_literal: true

desc 'task to update any mistmached coordinates with geocoder gem.'
task fix_coord_mismatch: :environment do
  results = Institution.approved_institutions(Version.last)
  by_country = results.select { |r| r.country.present? && r.country != 'USA' && r.state.present? }
  by_address = results.select { |r| r.address.present? && r.city.present? && r.state.present? && r.country == 'USA' }

  if by_country.present?
    by_country.each do |result|
      geocoded_country = Geocoder.coordinates(result.physical_country)
      update_mismatch(result, geocoded_country) if geocoded_country.present?
    end
  end

  if by_address.present?
    by_address.each do |result|
      # checks first addresss
      geocoded = Geocoder.coordinates("#{result.address}, #{result.city}, #{result.state}, #{result.zip}")
      if geocoded.present?
        # if present will update record, else will check address_2 and adress_3 fields
        update_mismatch(result, geocoded)
      else
        geocoded2 = Geocoder.coordinates("#{result.address_2}, #{result.city}, #{result.state}, #{result.zip}")
        geocoded3 = Geocoder.coordinates("#{result.address_3}, #{result.city}, #{result.state}, #{result.zip}")
        update_mismatch(result, geocoded2) if geocoded2.present?
        update_mismatch(result, geocoded3) if geocoded3.present?
      end
    end
  end
end

def update_mismatch(result, geocoded_coord)
  if geocoded_coord.present? && result.latitude.present? && result.longitude.present?
    lat = geocoded_coord[0]
    long = geocoded_coord[1]
    if lat.round(2) != result.latitude.round(2) || long.round(2) != result.longitude.round(2)
      org_lat = result.latitude
      org_long = result.longitude
      puts "updated #{result.institution} from [lat: #{org_lat}, long: #{org_long}] to [lat: #{lat}, long: #{long}]"
      result.update(latitude: lat, longitude: long)
    end
  end
end
