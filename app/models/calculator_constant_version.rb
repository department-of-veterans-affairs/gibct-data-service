# frozen_string_literal: true

class CalculatorConstantVersion < ImportableRecord
  CSV_CONVERTER_INFO = {
    'name' => { column: :name, converter: Converters::UpcaseConverter },
    'value' => { column: :float_value, converter: Converters::NumberConverter },
    'description' => { column: :description, converter: Converters::BaseConverter }
  }.freeze

  belongs_to :version

  validates :name, uniqueness: { scope: :version_id }, presence: true
  validates :float_value, presence: true
end
