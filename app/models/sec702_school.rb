# frozen_string_literal: true

class Sec702School < ApplicationRecord
  include CsvHelper

  CSV_CONVERTER_INFO = {
    'facility code' => { column: :facility_code, converter: FacilityCodeConverter },
    'section_702' => { column: :sec_702, converter: BooleanConverter }
  }.freeze

  validates :facility_code, presence: true
end
