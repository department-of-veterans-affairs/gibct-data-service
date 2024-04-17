# frozen_string_literal: true

# Right justifies facility_code to 8 characters using zeroes and ensures uppercase.
class Converters::FacilityCodeConverter < Converters::BaseConverter
  def self.convert(value)
    value = super(value.to_s)
    value = value.gsub('-', '') if value
    value.blank? ? nil : value.upcase.rjust(8, '0')
  end
end
