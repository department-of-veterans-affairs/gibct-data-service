# frozen_string_literal: true

# Mostly for display only fields not used in comparisons
class UpcaseConverter < BaseConverter
  def self.convert(value)
    value = super(value.to_s)
    value.blank? ? nil : value.upcase
  end
end
