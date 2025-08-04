# frozen_string_literal: true

module ApplicationHelper
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

  # rubocop:disable Rails/OutputSafety
  # Dynamically generate import entries for stimulus controllers in application.html.erb
  # Necessary because javascript_importmap_tags helper does not accept nonce argument
  def importmap_controller_assets
    assets = controller_paths.map do |path|
      file = File.basename(path, '.js')
      key = "controllers/#{file}"
      url = asset_path(key)
      "\"#{key}\": \"#{url}\""
    end
    (assets.empty? ? '' : ",\n        " + assets.join(",\n        ")).html_safe
  end

  # Dynamically generate link tags for stimulus controllers in application.html.erb
  # Necessary because javascript_importmap_tags helper does not accept nonce argument
  def importmap_controller_links
    links = controller_paths.map do |path|
      file = File.basename(path, '.js')
      url = asset_path("controllers/#{file}")
      tag.link(rel: 'modulepreload', href: url)
    end
    (links.empty? ? '' : "\n  " + links.join("\n  ")).html_safe
  end
  # rubocop:enable Rails/OutputSafety

  private

  def controller_paths
    Dir.glob(Rails.root.join('app/javascript/controllers/*.js')).sort
  end
end
