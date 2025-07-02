# frozen_string_literal: true

class ExampleSimpleJob < ApplicationJob
  def perform
    total_count = Institution.approved_institutions(Version.current_production).count
    Rails.logger.info("ExampleSimpleJob thinks there are #{total_count} Institutions for version #{Version.current_production.number}")
  end
end
