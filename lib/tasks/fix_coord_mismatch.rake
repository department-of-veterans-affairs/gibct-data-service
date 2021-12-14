# frozen_string_literal: true

desc 'task to update any mistmached coordinates with geocoder gem.'
task fix_coord_mismatch: :environment do
  results = Institution.approved_institutions(Version.last)
  by_address = results.select { |r| r.address.present? && r.city.present? }

  if by_address.present?
    by_address.each do |result|
      r = result
      # checks first addresss
      geocoded = Geocoder.coordinates("#{r.address}, #{r.city}, #{r.state}, #{r.zip}, #{r.country}")
      if geocoded.present?
        # if present will update record, else will check address_2 and adress_3 fields
        update_mismatch(r, geocoded)
      else
        geocoded2 = Geocoder.coordinates("#{r.address_2}, #{r.city}, #{r.state}, #{r.zip}, #{r.country}")
        geocoded3 = Geocoder.coordinates("#{r.address_3}, #{r.city}, #{r.state}, #{r.zip}, #{r.country}")
        update_mismatch(r, geocoded2) if geocoded2.present?
        update_mismatch(r, geocoded3) if geocoded3.present?
      end
    end
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
        result.update(latitude: lat, longitude: long)
      end
    else
      puts "updated #{int} from [lat: #{result.latitude}, long: #{result.longitude}] to [lat: #{lat}, long: #{long}]"
      result.update(latitude: lat, longitude: long)
    end
  end
end
