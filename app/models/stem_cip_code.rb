# frozen_string_literal: true

class StemCipCode < ImportableRecord
  CSV_CONVERTER_INFO = {
    'two_digit_series' => { column: :two_digit_series, converter: NumberConverter },
    '2010_cip_code' => { column: :twentyten_cip_code, converter: BaseConverter },
    'cip_code_title' => { column: :cip_code_title, converter: BaseConverter }
  }.freeze

  validates :two_digit_series, presence: true
  validates :twentyten_cip_code, numericality: true
end
