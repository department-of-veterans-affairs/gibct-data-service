# frozen_string_literal: true

# Right justifies cross (ipeds) to 6 characters using 0s.
class CrossConverter < BaseConverter
  def self.convert(value)
    value = super(value)
    value.blank? ? nil : value.rjust(6, '0')
  end
end
