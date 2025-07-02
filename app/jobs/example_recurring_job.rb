# frozen_string_literal: true

class ExampleRecurringJob < ApplicationJob
  def perform
    Rails.logger.info("ExampleRecurringJob has run at #{Time.zone.now}")
  end
end
