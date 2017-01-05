# frozen_string_literal: true

# Strips and converts string to number
class IntegerConverter < BaseConverter
  def self.convert(value)
    value = super(value)
    value.blank? ? nil : value.to_i
  end
end
