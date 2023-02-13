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
    # for when you upload a spreadsheet with a date/time field to the databse with a date-only field, then export
    # to a csv and re-upload, this handles the date-only field properly
    rescue TypeError
      value.to_date.strftime('%m/%d/%Y')
    end
  end
end
