# frozen_string_literal: true
class BaseConverter
  def self.convert(value)
    return value if value.nil? || !value.is_a?(String)

    value = value.tr('"', '').downcase.strip
    %w(none null privacysuppressed .).include?(value) ? nil : value
  end
end
