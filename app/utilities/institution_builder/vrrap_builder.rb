# frozen_string_literal: true

module InstitutionBuilder
  class VrrapBuilder
    extend Common

    def self.build(version_id)
      str = <<-SQL
        UPDATE institutions SET vrrap = vrrap_providers.vaco
        FROM vrrap_providers
        WHERE institutions.facility_code = vrrap_providers.facility_code
        AND institutions.version_id = #{version_id}
      SQL

      Institution.connection.update(str)
    end
  end
end
