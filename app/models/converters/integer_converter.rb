# frozen_string_literal: true

# Strips and converts string to number
class IntegerConverter < BaseConverter
  def self.convert(value)
    value = super(value)

    return value unless value.respond_to? :to_i
    value.blank? ? nil : value.to_i
  end
end
