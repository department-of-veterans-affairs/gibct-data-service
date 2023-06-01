# frozen_string_literal: true

class AccreditationDateTimeConverter < BaseConverter
  def self.convert(value)
    value = super(value)
    return nil if value.blank?

    begin
      return value.to_date if value.is_a?(DateTime)

      return value if value.is_a?(Date)

      # Accreditation Date format
      date = DateTime.strptime(value, '%m/%d/%Y %H:%M:%S %p').to_date
      return date if date.is_a?(Date)

      nil
    rescue ArgumentError
      nil

    # for when you upload a spreadsheet with a date/time field to the databse with a date-only field, then export
    # to a csv and re-upload, this handles the date-only field properly
    rescue TypeError
      value.to_date.strftime('%m/%d/%Y')
    end
  end
end
