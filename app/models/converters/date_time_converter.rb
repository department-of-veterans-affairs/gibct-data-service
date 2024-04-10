# frozen_string_literal: true

class Converters::DateTimeConverter < Converters::BaseConverter
  def self.convert(value)
    value = super(value)
    return nil if value.blank?

    begin
      return value.to_date if value.instance_of?(DateTime)

      return value if value.instance_of?(Date)

      # Added this here because you can't dynamically decide to use the Converters::DateConverter or DateTimeConverter.
      # It is declared as part of the model's upload. There's a situation with the complaint model where the
      # initial upload type is a date/time but when an export is performed, it gets exported as a date. The upload
      # of the exxport is a string of the form "yyyy-mm-dd". We have to be able to handle this situation.
      return Date.parse(value) if value.instance_of?(String) && value.match?(/\d{4}-\d{2}-\d{2}/)

      Date.strptime(value, '%m/%d/%Y')
    rescue ArgumentError
      nil
    # for when you upload a spreadsheet with a date/time field to the databse with a date-only field, then export
    # to a csv and re-upload, this handles the date-only field properly
    rescue TypeError
      value.to_date.strftime('%m/%d/%Y')
    end
  end
end
