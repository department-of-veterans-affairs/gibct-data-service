# frozen_string_literal: true

# Converts single-character value into abbreviation for OJT/Apprenticeship types
class Converters::OjtAppTypeConverter < Converters::BaseConverter
  OJT_APP_TYPES = {
    'G' => 'OJT', # On the Job Training
    'K' => 'APP', # Apprenticeship
    'P' => 'NPOJT', # Non Pay OJT
    'E' => 'NPFA' # Non Pay Federal Agency
  }.freeze

  def self.convert(value)
    value = super(value.to_s)
    return nil if value.blank?

    OJT_APP_TYPES[value.try(&:upcase)]
  end
end
