class PerformInstitutionTablesMaintenanceJob < ApplicationJob
  # frozen_string_literal: true

  queue_as :default

  TABLES = %w[ caution_flags institution_programs versioned_school_certifying_officials
               yellow_ribbon_programs institution_category_ratings institutions
               zipcode_rates versions].freeze

  def perform
    TABLES.each do |table|
      vacuum_and_analyze(table)
    end
  end

  def vacuum_and_analyze(table)
    ActiveRecord::Base.connection.execute("VACUUM FULL ANALYZE #{table}")
    Rails.logger.info "Vacuuming #{table}"
  end
end
