# frozen_string_literal: true

class SchoolRatingConverter < BaseConverter
  def self.convert(value)
    # allow non-numeric values and let validation handle it
    return value unless value.is_a? Numeric

    value = value.to_i
    value = 5 if value > 5
    value = nil if value <= 0
    value
  end
end
