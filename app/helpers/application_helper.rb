module ApplicationHelper
  #############################################################################
  ## to_a_tag
  ## Creates a properly formatted a tag.
  #############################################################################
  def to_a_tag(label, url, params = {})
    label = url if label.blank?

    str = %(<a href="#{url})
    var_values = params.to_query

    str += '?' + URI.encode(var_values) unless var_values.blank?
    str + %(">#{label}</a>)
  end

  #############################################################################
  ## to_uri
  ## Creates a properly formatted a tag.
  #############################################################################
  def to_uri(url, params = {})
    return '' if url.blank?

    var_values = params.to_query
    url += '?' + URI.encode(var_values) unless var_values.blank?

    url
  end

  #############################################################################
  ## pretty_controller_name
  ## Converts a controller name to a singularized title.
  #############################################################################
  def pretty_controller_name(name = '')
    name.split('_').map(&:capitalize).join(' ').singularize
  end

  #############################################################################
  ## get_path
  ## Returns the portion of a path that is between the opening / and the
  ## first non [/ or \w] encountered, which conveniently would be a ?.
  ## Note: the regex /^[\w+|\/]+/ does this.
  #############################################################################
  def get_path(fullpath = '')
    (fullpath || '').scan(%r{^[\w+|\/]+})[0]
  end

  #############################################################################
  ## active_path
  ## Returns true if the href and current_path are the same. Used to test
  ## a link's href path against the current request path to see if we are
  ## at the link's page.
  #############################################################################
  def active_path?(href, current_path = '')
    href == get_path(current_path)
  end

  #############################################################################
  ## draw_link
  ## Returns a bootstrap nav-bar link, that is marked active if the href is
  ## the same as the current request path.
  #############################################################################
  def draw_link(href, label, current_path = '')
    active = active_path?(href, current_path)

    l = '<li'
    l += active ? ' class="active">' : '>'
    l += %(<a href="#{href}">#{label})
    l += active ? ' <span class="sr-only">(current)</span>' : ''
    l + '</a></li>'
  end

  #############################################################################
  ## draw_controller
  ## Returns a bootstrap nav-bar dropdown, that is marked active if the
  ## controller's name is the same as the current controller's name.
  #############################################################################
  def draw_controller(controller, *actions)
    active = controller == controller_name

    l = '<li'
    l += active ? ' class="dropdown active">' : ' class="dropdown">'
    l += '<a href="#" class="dropdown-toggle" data-toggle="dropdown" '
    l += 'role="button" aria-haspopup="true" aria-expanded="false">'
    l += "#{controller.split('_').map(&:capitalize).join(' ')} "
    l += '<span class="caret"></span></a>'
    l += '<ul class="dropdown-menu">'

    actions.each do |action|
      case action
      when :index
        path = send((controller + '_path').to_sym)

        l += draw_link(path, 'List')
      when :new
        path = send(('new_' + controller.chomp('s') + '_path').to_sym, 'AccreditationCsvFile')

        l += draw_link(path, 'New')
      end
    end

    l + '</ul></li>'
  end
end
