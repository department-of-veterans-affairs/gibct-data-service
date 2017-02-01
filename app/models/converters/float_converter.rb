# frozen_string_literal: true

# Strips and converts string to number
class FloatConverter < BaseConverter
  def self.convert(value)
    value = super(value)
    value.blank? ? nil : value.to_f
  end
end
