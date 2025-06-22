# frozen_string_literal: true

class CalculatorConstant < ImportableRecord
  CSV_CONVERTER_INFO = {
    'name' => { column: :name, converter: Converters::UpcaseConverter },
    'value' => { column: :float_value, converter: Converters::NumberConverter },
    'description' => { column: :description, converter: Converters::BaseConverter }
  }.freeze

  default_scope { order('name') }

  validates :name, uniqueness: true, presence: true
  validates :float_value, presence: true

  # Support for GIBCT using value
  def value
    float_value
  end

  # removing this breaks the caclulator constant request spec (v0)
  # TODO: remove without breaking functionality
  scope :version, lambda { |version|
    # TODO: where(version: version)
  }
end
