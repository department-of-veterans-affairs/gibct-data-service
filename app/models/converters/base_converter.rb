# frozen_string_literal: true
class BaseConverter
  def self.convert(value)
    value = value.try(:strip)
    %w(none null privacysuppressed).include?(value.try(:downcase)) ? nil : value
  end
end
