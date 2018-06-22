# frozen_string_literal: true

class DateConverter < BaseConverter
  def self.convert(value)
    value = super(value)

    return nil if value.blank?

    begin
      Date.strptime(value, '%m/%d/%Y')
    rescue ArgumentError
      nil
    end
  end
end
