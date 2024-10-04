# frozen_string_literal: true

class Lce::Exam < ImportableRecord
  CSV_CONVERTER_INFO = {
    'name' => { column: :name, converter: Converters::BaseConverter },
    'description' => { column: :description, converter: Converters::BaseConverter },
    'dates' => { column: :dates, converter: Converters::DateTimeConverter },
    'amount' => { column: :amount, converter: Converters::NumberConverter }
  }.freeze

  belongs_to :institution, :class_name => 'Lce::Institution'
end
