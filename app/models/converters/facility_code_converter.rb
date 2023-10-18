# frozen_string_literal: true

# Right justifies facility_code to 8 characters using 0s and ensures uppercase.
class FacilityCodeConverter < BaseConverter
  def self.convert(value)
    # rubocop:disable Style/IfUnlessModifier
    if value
      value = super(value.to_s)
      value = value.gsub('-', '') if value
    end
    # rubocop:enable Style/IfUnlessModifier
    value.blank? ? nil : value.upcase.rjust(8, '0')
  end
end
