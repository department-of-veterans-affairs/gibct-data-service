# frozen_string_literal: true

module MessagesHelper
  def latest_preview_status
    @latest_preview_status ||= PreviewGenerationStatusInformation.last
  end

  def preview_generation_started?
    latest_preview_status.present?
  end
end