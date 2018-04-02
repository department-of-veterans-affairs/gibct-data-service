# frozen_string_literal: true

# Right justifies ope to 8 characters using 0s.
class OpeConverter
  def self.convert(value)
    value = value.to_s
    value = value.match(/\A(NONE|\.)\z/i).nil? ? value : nil
    value.blank? ? nil : value.rjust(8, '0')
  end
end
