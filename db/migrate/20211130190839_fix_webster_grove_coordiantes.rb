class FixWebsterGroveCoordiantes < ActiveRecord::Migration[6.0]
  def change
  	@version = Version.last
  	@query = ActionController::Parameters.new({"distance"=>75.0, "latitude"=>38.5926, "longitude"=>-90.3573, "format"=>"json", "controller"=>"v1/institutions", "action"=>"location", "institution"=>{}})
  	location_results = Institution.approved_institutions(@version).location_search(@query).filter_result_v1(@query)
  	results = location_results.location_select(@query).location_order
  	results.each do |result|
  		if result.physical_country.present? && result.physical_country != "USA"
  			geocoded_country = Geocoder.coordinates(result.physical_country)
  			lat = geocoded_country[0]
  			long = geocoded_country[1]
  			if lat.round(2) != result.latitude.round(2) || long.round(2) != result.longitude.round(2)
  				org_lat = result.latitude
  				org_long = result.longitude
  				result.update_attributes(latitude: lat,  longitude: long)
  				puts "Updated #{result.institution} from latitude: #{org_lat}, longitude: #{org_long} to latitude: #{lat}, longitude: #{long}"
  			end
  		else
	  		#re-geocodes by address and updates if mismatch is found
	  		geocoded_coord = Geocoder.coordinates("#{result.address}, #{result.city}, #{result.state} ")
	  		if geocoded_coord.present?
	  			lat = geocoded_coord[0]
	    		long = geocoded_coord[1]
	    		if lat.round(2) != result.latitude.round(2) || long.round(2) != result.longitude.round(2)
	    			org_lat = result.latitude
	    			org_long = result.longitude
	    			result.update_attributes(latitude: lat,  longitude: long)
	    			puts "Updated #{result.institution} from latitude: #{org_lat}, longitude: #{org_long} to latitude: #{lat}, longitude: #{long}"
	    		end
	  		else
	  			#if can't find re-geocodes by address_2 and updates if mismatch is found
	  			geocoded_coord_2 = Geocoder.coordinates("#{result.city}, #{result.state}, #{result.physical_country}")
	    		if geocoded_coord_2.present?
	    			lat = geocoded_coord_2[0]
	    			long = geocoded_coord_2[1]
		    		if lat.round(2) != result.latitude.round(2) || long.round(2) != result.longitude.round(2)
		    			org_lat = result.latitude
		    			org_long = result.longitude
		    			result.update_attributes(latitude: lat,  longitude: long)
		    			puts "Updated #{result.institution} from latitude: #{org_lat}, longitude: #{org_long} to latitude: #{lat}, longitude: #{long}"
		    		end
		    	else
		    		#if can't find re-geocodes by zipcode and updates if mismatch is found
		    		geocoded_coord_zip = Geocoder.coordinates("#{result.physical_zip}, #{result.physical_country}")
	    			if geocoded_coord_zip.present?
	    				lat = geocoded_coord_zip[0]
	    				long = geocoded_coord_zip[1]
		    			if lat.round(2) != result.latitude.round(2) || long.round(2) != result.longitude.round(2)
			    			org_lat = result.latitude
			    			org_long = result.longitude
			    			result.update_attributes(latitude: lat,  longitude: long)
			    			puts "Updated #{result.institution} from latitude: #{org_lat}, longitude: #{org_long} to latitude: #{lat}, longitude: #{long}"
			    		end
			    	else
			    		puts "#{result.institution} could not be updated"
			    	end
		    	end
	  		end
	  	end
  	end
  end
end
