module Alertable
  extend ActiveSupport::Concern

  included do
  end

  class_methods do
    ###########################################################################
    ## pretty_error
    ## Wraps an array of messages (presumably errors) in a list.
    ###########################################################################
    def pretty_error(label = "", errors = [])
      msg = errors.inject("<ul>") do |m, error|
        m += "<li>#{error}</li>"
      end + "</ul>"

      pstr = ""
      pstr += "<p>#{label}</p>" if label.present?
      pstr += msg if errors.present?

      pstr
    end
  end
end
