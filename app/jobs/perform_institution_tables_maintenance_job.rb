# frozen_string_literal: true

class PerformInstitutionTablesMaintenanceJob < ApplicationJob
  queue_as :default

  def perform
    DbCleanup.vacuum_and_analyze_preview_tables
  end
end
