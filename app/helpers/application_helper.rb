# frozen_string_literal: true

module ApplicationHelper
  include CommonInstitutionBuilder::VersionGeneration

  def controller_label_for_header
    case controller.controller_name
    when 'accreditation_type_keywords'
      'Accreditation keyword'
    when 'uploads'
      'Uploads / Online Changes'
    when 'calculator_constants'
      controller.controller_name.humanize
    else
      controller.controller_name.humanize.singularize
    end
  end

  def active_link?(path, method = 'GET')
    begin
      h = Rails.application.routes.recognize_path(path, method: method)
    rescue ActionController::RoutingError
      return false
    end

    controller.controller_name == h[:controller] && controller.action_name == h[:action]
  end

  def li_active_class(path, method = 'GET')
    active_link?(path, method) ? 'active' : ''
  end

  def link_if_not_active(body, path, method = 'GET')
    active_link?(path, method) ? content_tag(:a, body) : link_to(body, path)
  end

  # Wraps an array of error messages in an html list with a label (optional) above it
  def pretty_error(errors, error_label = '')
    return '' if errors.blank? && error_label.blank?

    content_tag(:div, class: 'errors') do
      concat(content_tag(:p, error_label)) if error_label.present?

      if errors.present?
        concat(
          content_tag(:ul) do
            errors = [errors] unless errors.is_a? Array
            errors.map do |error|
              concat content_tag(:li, error)
            end
          end
        )
      end
    end
  end

  def format_url(url)
    return url if development?

    "/gids/#{url}"
  end

  # rubocop:disable Rails/OutputSafety
  def javascript_importmap_tags_with_nonce
    tags = javascript_importmap_tags('main').to_s
    tags.gsub(/<script /, '<script nonce="**CSP_NONCE**" ').html_safe
  end
  # rubocop:enable Rails/OutputSafety

  def preview_generation_started?
    PreviewGenerationStatusInformation.exists?
  end

  def preview_generation_completed?
    return unless preview_generation_started?

    completed = false

    pgsi = PreviewGenerationStatusInformation.last
    if pgsi.current_progress.start_with?(PUBLISH_COMPLETE_TEXT) ||
       pgsi.current_progress.start_with?('There was an error')
      completed = true
      PreviewGenerationStatusInformation.delete_all
      # maintain the indexes and tables in the local, dev & staging envs.
      # The production env times out and periodic maintenance should be run
      # in production anyway.
      PerformInsitutionTablesMaintenanceJob.perform_later unless production?
    end

    completed
  end
end
