# frozen_string_literal: true
module Alertable
  extend ActiveSupport::Concern

  included do
  end

  class_methods do
    # Wraps an array of error messages in an html list with a label (optional) above it
    def pretty_error(errors, label = '')
      return '' if errors.blank?

      msg = errors.inject('<ul>') do |m, error|
        m + "<li>#{error}</li>"
      end + '</ul>'

      pstr = ''
      pstr += "<p>#{label}</p>" if label.present?
      pstr += msg if errors.present?

      pstr
    end
  end
end
