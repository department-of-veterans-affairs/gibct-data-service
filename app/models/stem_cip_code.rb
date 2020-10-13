# frozen_string_literal: true

class StemCipCode < ApplicationRecord


  CSV_CONVERTER_INFO = {
    'two-digit series' => { column: :two_digit_series, converter: NumberConverter },
    '2010 cip code' => { column: :twentyten_cip_code, converter: BaseConverter },
    'cip code title' => { column: :cip_code_title, converter: BaseConverter }
  }.freeze

  validates :two_digit_series, presence: true
  validates :twentyten_cip_code, numericality: true
end
