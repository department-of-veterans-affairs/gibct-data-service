# frozen_string_literal: true

class Sec702 < ImportableRecord
  CSV_CONVERTER_INFO = {
    'state' => { column: :state, converter: Converters::StateConverter },
    'state_full_name' => { column: :state_full_name, converter: Converters::BaseConverter },
    'sec702' => { column: :sec_702, converter: Converters::BooleanConverter }
  }.freeze

  validates :state, inclusion: { in: Converters::StateConverter::STATES.keys }
end
