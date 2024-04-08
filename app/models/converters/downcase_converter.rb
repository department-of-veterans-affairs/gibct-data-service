# frozen_string_literal: true

class Converters::DowncaseConverter < Converters::BaseConverter
  def self.convert(value)
    value = super(value.to_s)
    value.blank? ? nil : value.downcase
  end
end
