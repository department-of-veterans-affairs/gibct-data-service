# frozen_string_literal: true

class DateTimeConverter < BaseConverter
  def self.convert(value)
    value = super(value)
    return nil if value.blank?

    begin
      return value.to_date if value.instance_of?(DateTime)

      Date.strptime(value.to_date, '%m/%d/%Y')
    rescue ArgumentError
      nil
    end
  end
end
