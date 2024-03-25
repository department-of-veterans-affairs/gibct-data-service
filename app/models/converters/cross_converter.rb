# frozen_string_literal: true

class Converters::CrossConverter < Converters::BaseConverter
  def self.convert(value)
    value = super(value.to_s)
    value.blank? ? nil : value.upcase
  end
end
