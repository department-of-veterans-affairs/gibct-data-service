# frozen_string_literal: true

module MessagesHelper
  # Message is persisted across page reloads because of data-turbo-permanent,
  # but in case of a hard reload e.g. we want to render latest status server side
  def latest_preview_status
    @latest_preview_status ||= PreviewGenerationStatusInformation.latest
  end

  def preview_generation_started?
    latest_preview_status.present?
  end
end
