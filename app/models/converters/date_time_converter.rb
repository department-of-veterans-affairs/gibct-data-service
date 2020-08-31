# frozen_string_literal: true

class DateTimeConverter < BaseConverter
  def self.convert(value)
    value = super(value)

    return nil if value.blank?

    begin
      DateTime.parse(value)
    rescue ArgumentError
      nil
    end
  end
end
