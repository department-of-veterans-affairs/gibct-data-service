# frozen_string_literal: true

module InstitutionBuilder
  class LatLongBuilder
    extend Common

    def self.missing_lat_long_rows(version_id)
      current_version = Version.current_production

      from_sql = <<-SQL
        institutions LEFT OUTER JOIN institutions prod_institutions ON (
            institutions.facility_code = prod_institutions.facility_code
            AND prod_institutions.version_id = :current_version
            AND (
              institutions.physical_address_1 != prod_institutions.physical_address_1 OR
              institutions.physical_address_2 != prod_institutions.physical_address_2 OR
              institutions.physical_address_3 != prod_institutions.physical_address_3 OR
              institutions.physical_city != prod_institutions.physical_city OR
              institutions.physical_state != prod_institutions.physical_state OR
              institutions.physical_country != prod_institutions.physical_country OR
              institutions.physical_zip != prod_institutions.physical_zip
            )
          )
      SQL

      where_sql = <<-SQL
          (
            institutions.latitude IS NULL OR institutions.longitude IS NULL or prod_institutions.id IS NOT NULL
          )
          AND institutions.version_id = :preview_version
          AND institutions.approved IS true
      SQL

      from_query = Institution.sanitize_sql_for_conditions([from_sql, current_version: current_version])
      where_query = Institution.sanitize_sql_for_conditions([where_sql, preview_version: version_id])

      Institution.from(from_query).where(where_query)
    end

    def self.build(version_id)
      values_list = []
      failed = []

      institutions = missing_lat_long_rows(version_id)
      if institutions.count > (Settings.geocode.mapbox.batch * Settings.geocode.mapbox.max_calls)
        return 'Too many institutions are missing latitude and longitude values. Please use CensusLatLong CSV process.'
      end

      # institutions.each do |row|
      #   result = Geocoder.search(row.physical_address_location).first
      #   if result
      #     coordinates = result.coordinates
      #     values_list << "('#{row.facility_code}', #{coordinates[0]}, #{coordinates[1]})"
      #   else
      #     failed << "#{row.facility_code} | #{row.physical_address_location}"
      #   end
      # end

      update_sql = <<-SQL
        UPDATE institutions SET
          latitude = lat_long_list.latitude,
          longitude = lat_long_list.longitude
        FROM (values
          :values_list
        ) lat_long_list(facility_code, latitude, longitude)
        WHERE institutions.facility_code = lat_long_list.facility_code
        AND institutions.version_id = #{version_id}
      SQL

      update_query = Institution.sanitize_sql_for_conditions([update_sql,
                                                              values_list: values_list.compact.join(', ')])

      Institution.connection.update(update_query)
      true
    end
  end
end
