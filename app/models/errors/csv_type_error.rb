# frozen_string_literal: true
class CsvTypeError < StandardError
  attr_reader :csv_type

  def initialize(type)
    @csv_type = type
    super("#{type} is not a currently supported CSV type.")
  end
end
