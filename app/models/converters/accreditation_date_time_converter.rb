# frozen_string_literal: true

class AccreditationDateTimeConverter < BaseConverter
  def self.convert(value)
    value = super(value)
    return nil if value.blank?

    begin
      date = nil

      # rubocop:disable Style/EmptyCaseCondition
      case
      when value.is_a?(DateTime)
        date = value.to_date
      when value.is_a?(Date)
        date = value

      # Accreditation Date format
      when value.is_a?(String) && value.length > 10
        begin
          date = DateTime.strptime(value, '%m/%d/%Y %H:%M:%S %p').to_date
        rescue ArgumentError
          date = DateTime.strptime(value, '%m/%d/%Y %H:%M').to_date
        end
      when value.is_a?(String)
        begin
          date = DateTime.strptime(value, '%Y-%m-%d').to_date
        rescue ArgumentError
          date = DateTime.strptime(value, '%m/%d/%Y').to_date
        end
      end
      # rubocop:enable Style/EmptyCaseCondition

      date
    rescue ArgumentError
      nil

    # for when you upload a spreadsheet with a date/time field to the databse with a date-only field, then export
    # to a csv and re-upload, this handles the date-only field properly
    rescue TypeError
      value.to_date.strftime('%m/%d/%Y')
    end
  end
end
