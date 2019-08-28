# frozen_string_literal: true

class BaseConverter
  def self.convert(value)
    return value if value.nil? || !value.is_a?(String)

    value = value.tr('"', '').strip
    value.match(/\A(none|null|privacysuppressed|\.)\z/i).nil? ? value : nil
  end
end
