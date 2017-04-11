# frozen_string_literal: true
class CsvHeaderError < StandardError
  attr_reader :csv_type, :missing, :extra

  def initialize(csv_type, missing, extra)
    @csv_type = csv_type
    @missing = missing
    @extra = extra

    msg = "#{@csv_type} has an issue with headers. "
    msg += "Missing headers: #{@missing.join(', ')}. " unless @missing.blank?
    msg += "Extra headers: #{@extra.join(', ')}." unless @extra.blank?

    super(msg)
  end
end
