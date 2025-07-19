# frozen_string_literal: true

module InstitutionBuilder
  class CalculatorConstantVersionBuilder
    extend Common

    def self.build(version_id)
      str = <<-SQL
        INSERT INTO calculator_constant_versions
          (version_id, "name", float_value, "description", created_at, updated_at)
        SELECT
          #{version_id} as version_id, "name", float_value, "description", CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        FROM calculator_constants
      SQL

      sql = CalculatorConstantVersion.send(:sanitize_sql, [str])
      Institution.connection.execute(sql)
    end
  end
end
