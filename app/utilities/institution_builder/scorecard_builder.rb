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
  end
end
