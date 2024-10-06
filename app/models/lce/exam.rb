# frozen_string_literal: true

module Lce
  class Exam < ImportableRecord
    CSV_CONVERTER_INFO = {
      'name' => { column: :name, converter: Converters::BaseConverter },
      'description' => { column: :description, converter: Converters::BaseConverter },
      'dates' => { column: :dates, converter: Converters::DateTimeConverter },
      'amount' => { column: :amount, converter: Converters::NumberConverter },
      'institution_id' => { column: :institution_id, converter: Converters::NumberConverter }
    }.freeze
  
    belongs_to :institution, :class_name => 'Lce::Institution'
  end
end
