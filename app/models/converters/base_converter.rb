# frozen_string_literal: true
class BaseConverter
  def self.convert(value)
    return value unless value.is_a? String

    %w(none null privacysuppressed).include?(value.try(:downcase)) ? nil : value.try(:strip).try(:tr, '"', '')
  end
end
