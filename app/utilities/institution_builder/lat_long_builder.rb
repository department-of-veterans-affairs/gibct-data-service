# frozen_string_literal: true

module InstitutionBuilder
  class LatLongBuilder
    extend Common

    # interpolated_longitude_latitude looks like "-76.92744,38.845985"
    def self.build(version_id)
      str = <<-SQL
        UPDATE institutions SET
          latitude = CAST(SPLIT_PART(interpolated_longitude_latitude,',',1) AS double precision ),
          longitude = CAST(SPLIT_PART(interpolated_longitude_latitude,',',2) AS double precision )
        FROM census_lat_longs
        WHERE institutions.facility_code = census_lat_longs.facility_code
          AND (institutions.latitude IS NULL OR institutions.longitude IS NULL)
          AND institutions.version_id = #{version_id}
          AND CAST(SPLIT_PART(interpolated_longitude_latitude,',',1) AS double precision ) BETWEEN -90 AND 90
          AND CAST(SPLIT_PART(interpolated_longitude_latitude,',',2) AS double precision ) BETWEEN -180 AND 180
      SQL

      Institution.connection.update(str)
      '' + still_missing_lat_long(version_id)
    end

    # rubocop:disable Metrics/MethodLength
    def self.still_missing_lat_long(version_id)
      current_version = Version.current_production

      str = <<-SQL
        UPDATE institutions SET
          latitude = prod_institutions.latitude,
          longitude = prod_institutions.longitude
        FROM institutions LEFT OUTER JOIN institutions prod_institutions ON (
            institutions.facility_code = prod_institutions.facility_code
            AND prod_institutions.version_id = :current_version
            AND prod_institutions.longitude IS NOT NULL
            AND prod_institutions.latitude IS NOT NULL
            AND institutions.physical_address_1 = prod_institutions.physical_address_1
            AND institutions.physical_address_2 = prod_institutions.physical_address_2
            AND institutions.physical_address_3 = prod_institutions.physical_address_3
            AND institutions.physical_city = prod_institutions.physical_city
            AND institutions.physical_state = prod_institutions.physical_state
            AND institutions.physical_country = prod_institutions.physical_country
            AND institutions.physical_zip = prod_institutions.physical_zip
            AND prod_institutions.approved IS true
          )
        WHERE (institutions.latitude IS NULL OR institutions.longitude IS NULL)
		      AND prod_institutions.id IS NOT NULL
          AND institutions.version_id = :preview_version
          AND institutions.approved IS true
      SQL

      Institution.connection.update(Institution.sanitize_sql_for_conditions([str,
                                                                             current_version: current_version.id,
                                                                             preview_version: version_id]))

      ''
    end
    # rubocop:enable Metrics/MethodLength
  end
end
