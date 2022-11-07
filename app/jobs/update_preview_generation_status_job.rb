class UpdatePreviewGenerationStatusJob < ApplicationJob
  # frozen_string_literal: true

  queue_as :default

  def perform(message)
    PreviewGenerationStatusInformation.create!(current_progress: message)
  end
end
