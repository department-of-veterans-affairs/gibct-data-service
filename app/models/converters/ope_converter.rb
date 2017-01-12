# frozen_string_literal: true

# Right justifies ope to 8 characters using 0s.
class OpeConverter < BaseConverter
  def self.convert(value)
    value = super(value.to_s)
    value.blank? ? nil : value.rjust(8, '0')
  end
end
