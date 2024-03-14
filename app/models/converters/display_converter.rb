# frozen_string_literal: true

# Mostly for display only fields not used in comparisons
class Converters::DisplayConverter < Converters::BaseConverter
  def self.convert(value)
    value = super(value.to_s)
    value.blank? ? nil : value.gsub(/\w+/, &:capitalize)
  end
end
