class CsvTypeError < StandardError
  attr_reader :csv_type

  def initialize(type)
    @csv_type = csv_type
    super("#{csv_type} is not a currently supported CSV type.")
  end
end
