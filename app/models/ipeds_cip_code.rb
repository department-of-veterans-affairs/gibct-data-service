# frozen_string_literal: true

class IpedsCipCode < ImportableRecord
  CSV_CONVERTER_INFO = {
    'unitid' => { column: :cross, converter: CrossConverter },
    'cipcode' => { column: :cipcode, converter: BaseConverter },
    'ctotalt' => { column: :ctotalt, converter: NumberConverter }
  }.freeze

  validates :cross, presence: true
  validates :cipcode, numericality: true
  validates :ctotalt, numericality: { only_integer: true }
end
