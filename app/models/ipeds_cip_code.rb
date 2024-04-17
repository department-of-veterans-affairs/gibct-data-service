# frozen_string_literal: true

class IpedsCipCode < ImportableRecord
  CSV_CONVERTER_INFO = {
    'unitid' => { column: :cross, converter: Converters::CrossConverter },
    'cipcode' => { column: :cipcode, converter: Converters::BaseConverter },
    'ctotalt' => { column: :ctotalt, converter: Converters::NumberConverter }
  }.freeze

  validates :cross, presence: true
  validates :cipcode, numericality: true
  validates :ctotalt, numericality: { only_integer: true }
end
