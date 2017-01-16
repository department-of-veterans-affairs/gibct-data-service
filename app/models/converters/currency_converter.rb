# frozen_string_literal: true

# Right justifies ope to 8 characters using 0s.
class CurrencyConverter < BaseConverter
  def self.convert(value)
    value = super(value.to_s)
    value.blank? ? nil : value.gsub(/[$,]/, '')
  end
end
