# frozen_string_literal: true

class InstitutionTablesMaintenanceJob < ApplicationJob
  queue_as :default

  def perform
    DbCleanup.vacuum_and_analyze_preview_tables
  end
end
