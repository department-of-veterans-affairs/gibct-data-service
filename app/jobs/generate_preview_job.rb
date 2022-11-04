class GeneratePreviewJob < ApplicationJob
  # frozen_string_literal: true

  queue_as :default

  def perform(current_user)
    InstitutionBuilder.run(current_user)
  end
end
