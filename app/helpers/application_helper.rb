module ApplicationHelper
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
    active_link?(path, method) ? "<a>#{body}</a>".html_safe : link_to(body, path)
  end
end
