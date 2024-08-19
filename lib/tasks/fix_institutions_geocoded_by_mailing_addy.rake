# frozen_string_literal: true

namespace :otos do
  # run this task locally and push the codebase to production
  desc 'task to fix insitutions geocoded by mailing address where it is different from physical address'
  task fix_institutions_geocoded_by_mailing_addy: :environment do
    latest_version = Version.last
    institutions_hash = {}

    institutions = Institution
                   .approved_institutions(latest_version)
                   .where(
                     'physical_address_1 != address_1 OR physical_address_2 != address_2 OR physical_address_3 != address_3 OR ' \
                     'physical_city != city OR physical_state != state OR physical_country != country OR physical_zip != zip'
                   ).order(:facility_code)

    institutions.each do |inst|
      institution_hash = {
        facility_code: inst.facility_code, institution: inst.institution,
        address_1: inst.address_1, address_2: inst.address_2, address_3: inst.address_3,
        city: inst.city, state: inst.state, zip: inst.zip, country: inst.country,
        physical_address_1: inst.physical_address_1, physical_address_2: inst.physical_address_2,
        physical_address_3: inst.physical_address_3,
        physical_city: inst.physical_city, physical_state: inst.physical_state, physical_zip: inst.physical_zip,
        physical_country: inst.physical_country, old_longitude: inst.longitude, old_latitude: inst.latitude
      }
      institutions_hash[inst.id] = institution_hash
    end

    search_geocoder = SearchGeocoder.new(latest_version)
    search_geocoder.results = institutions
    search_geocoder.by_address = institutions.where(physical_country: ['USA', nil])
    search_geocoder.country = institutions.where.not(physical_country: 'USA')
    search_geocoder.process_geocoder_address

    # reload after done
    institutions = Institution
                   .approved_institutions(latest_version)
                   .select(
                     :id, :facility_code, :institution,
                     :address_1, :address_2, :address_3, :city, :state, :zip, :country,
                     :physical_address_1, :physical_address_2, :physical_address_3,
                     :physical_city, :physical_state, :physical_zip, :physical_country,
                     :latitude, :longitude
                   ).where(
                     'physical_address_1 != address_1 OR physical_address_2 != address_2 OR physical_address_3 != address_3 OR ' \
                     'physical_city != city OR physical_state != state OR physical_country != country OR physical_zip != zip'
                   ).order(:facility_code)

    institutions.each do |inst|
      # get the institution from the hash
      institution_in_hash = institutions_hash[inst.id]
      # update the hash with the new coordinates
      institution_in_hash[:new_longitude] = inst.longitude
      institution_in_hash[:new_latitude] = inst.latitude
      # update in the hash
      institutions_hash[inst.id] = institution_in_hash
    end

    # write to file the institutions that will change
    file = File.open(Rails.root.join('tmp', 'institutions_report.txt'), 'w')
    institutions_array = institutions_hash.values
    institutions_array.each do |i|
      file.puts "fac cd: #{i[:facility_code]}, #{i[:institution]}"
      file.puts "addy1:  #{i[:address_1]}, #{i[:physical_address_1]}"
      file.puts "addy2:  #{i[:address_2]}, #{i[:physical_address_2]}"
      file.puts "addy3:  #{i[:address_3]}, #{i[:physical_address_3]}"
      file.puts "c/st/z: #{i[:city]} #{i[:state]} #{i[:zip]}, #{i[:physical_city]} #{i[:physical_state]} #{i[:physical_zip]}"
      file.puts "cntry:  #{i[:country]}, #{i[:physical_country]}"
      file.puts "coords: #{i[:old_longitude]}, #{i[:old_latitude]}, #{i[:new_longitude]}, #{i[:new_latitude]}"
      file.puts ''
    end
    file.close

    # Open a file for updating in production. This is the file we will use in the rake task to update the institutions
    # in production
    File.open(Rails.root.join('db', 'institutions_to_update.txt'), 'w') do |f|
      institutions.each { |inst| f.puts("#{inst.facility_code},#{inst.longitude},#{inst.latitude}") }
    end
  end

  # run this task in production
  desc 'update production institutions geocoded by mailing address.'
  task update_production_institutions_geocoded_by_mailing_addy: :environment do
    puts "Beg #{Time.current}"
    latest_version = Version.last
    File.open(Rails.root.join('db', 'institutions_to_update.txt')) do |file|
      file.each_line do |line|
        facility_code, longitude, latitude = line.strip.chomp.split(',')
        institution = Institution.find_by(facility_code: facility_code, version_id: latest_version.id)
        institution.update(longitude: longitude, latitude: latitude)
      end
    end
    puts "End #{Time.current}"
  end
end
