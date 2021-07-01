# frozen_string_literal: true

module InstitutionBuilder
  class ScorecardBuilder
    extend Common

    def self.build(version_id)
      str = <<-SQL
      UPDATE institutions SET #{columns_for_update(Scorecard)}, ialias = scorecards.alias
      FROM scorecards
      WHERE institutions.cross = scorecards.cross
      AND institutions.version_id = #{version_id}
      SQL

      Institution.connection.update(str)
    end

    def self.add_lat_lon_from_scorecard(version_id)
      str = <<-SQL
      UPDATE institutions SET latitude = scorecards.latitude, longitude = scorecards.longitude
      FROM scorecards
      WHERE institutions.cross = scorecards.cross
      AND institutions.version_id = #{version_id}
      AND (institutions.latitude IS NULL OR institutions.longitude IS NULL)
      AND scorecards.latitude BETWEEN -90 AND 90
      AND scorecards.longitude BETWEEN -180 AND 180
      SQL

      Institution.connection.update(str)
    end
  end
end
