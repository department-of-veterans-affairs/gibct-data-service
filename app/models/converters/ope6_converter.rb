# frozen_string_literal: true

# converts an ope to an ope6
class Ope6Converter < OpeConverter
  def self.convert(value)
    value = super(value.to_s)
    value.blank? ? nil : value[1, 5]
  end
end
