# frozen_string_literal: true
module ApplicationHelper
  # Renders a nav dropdown for the controller.
  def draw_controller_index_link(controller = 'dashboards')
    path = send("#{controller}_path".to_sym)
    label = controller.humanize.singularize

    if controller == controller_name
      %(<li class="active"><a href="#{path}">#{label}<span class="sr-only">(current)</span></a></li>)
    else
      %(<li><a href="#{path}">#{label}</a></li>)
    end
  end
end
