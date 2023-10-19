# frozen_string_literal: true

# Right justifies facility_code to 8 characters using zeroes and ensures uppercase.
class FacilityCodeConverter < BaseConverter
  def self.convert(value)
    value = super(value.to_s)
    value.blank? ? nil : value.upcase.rjust(8, '0')
  end
end
