# frozen_string_literal: true

class DateConverter < BaseConverter
  def self.convert(value)
    value = super(value)

    return nil if value.blank?

    begin
      return value if value.instance_of?(Date)

      # When exporting and importing a date, it can come back as a string. Currently observed yyyy-mm-dd.
      # Add more formats as needed.
      return Date.parse(value) if value.instance_of?(String) && value.match?(/\d{4}-\d{2}-\d{2}/)

      Date.strptime(value, '%m/%d/%Y')
    rescue ArgumentError
      nil
    end
  end
end
