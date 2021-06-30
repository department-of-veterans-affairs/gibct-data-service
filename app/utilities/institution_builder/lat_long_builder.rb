# frozen_string_literal: true

module InstitutionBuilder
  class LatLongBuilder
    extend Common

    def self.build(version_id)
      str = <<-SQL
        institutions.facility_code = census_lat_longs.facility_code
      SQL

      add_columns_for_update(version_id, CensusLatLong, str)
      false
    end
  end
end
