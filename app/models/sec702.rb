# frozen_string_literal: true
class Sec702 < ActiveRecord::Base
  include CsvHelper

  CSV_CONVERTER_INFO = {
    'state' => { column: :state, converter: StateConverter },
    'state full name' => { column: :state_full_name, converter: BaseConverter },
    'sec702' => { column: :sec_702, converter: BooleanConverter }
  }.freeze

  validates :state, inclusion: { in: StateConverter::STATES.keys }
end
