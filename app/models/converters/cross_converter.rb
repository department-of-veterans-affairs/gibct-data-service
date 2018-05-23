# frozen_string_literal: true

class CrossConverter < BaseConverter
  def self.convert(value)
    value = super(value.to_s)
    value.blank? ? nil : value.upcase
  end
end
