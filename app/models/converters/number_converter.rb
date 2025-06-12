# frozen_string_literal: true

class Converters::NumberConverter < Converters::BaseConverter
  def self.convert(value)
    value = super(value.to_s)
    value.blank? ? nil : value.gsub(/[$,+]/, '')
  end
end
