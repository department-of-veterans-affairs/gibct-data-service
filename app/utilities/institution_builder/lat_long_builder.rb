# frozen_string_literal: true

module InstitutionBuilder
  class LatLongBuilder
    extend Common

    # "-76.92744,38.845985"
    # interpolated_longitude_latitude
    def self.build(version_id)
      str = <<-SQL
        UPDATE institutions SET
          latitude = CAST(SPLIT_PART(interpolated_longitude_latitude,',',1) AS double precision ),
          longitude = CAST(SPLIT_PART(interpolated_longitude_latitude,',',2) AS double precision )
        FROM census_lat_longs
        WHERE institutions.facility_code = census_lat_longs.record_id_number
        AND (institutions.latitude IS NULL OR institutions.longitude IS NULL) 
        AND institutions.version_id = #{version_id}
        AND CAST(SPLIT_PART(interpolated_longitude_latitude,',',1) AS double precision ) BETWEEN -90 AND 90
        AND CAST(SPLIT_PART(interpolated_longitude_latitude,',',2) AS double precision ) BETWEEN -180 AND 180
      SQL

      Institution.connection.update(str)
      false
    end

    def self.still_missing_lat_long(version_id)

    end
  end
end
