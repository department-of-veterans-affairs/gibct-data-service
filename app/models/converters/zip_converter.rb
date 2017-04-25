# frozen_string_literal: true

# Right justifies zip to 5 characters using 0s.
class ZipConverter < BaseConverter
  def self.convert(value)
    value = super(value.to_s)
    value.blank? ? nil : value.rjust(5, '0')
  end
end
