# frozen_string_literal: true

class Program < ImportableRecord
  CSV_CONVERTER_INFO = {
    'facility_code' => { column: :facility_code, converter: Converters::FacilityCodeConverter },
    'institution_name' => { column: :institution_name, converter: Converters::InstitutionConverter },
    'program_type' => { column: :program_type, converter: Converters::BaseConverter },
    'description' => { column: :description, converter: Converters::BaseConverter },
    'full_time_undergraduate' => { column: :full_time_undergraduate, converter: Converters::BaseConverter },
    'graduate' => { column: :graduate, converter: Converters::BaseConverter },
    'full_time_modifier' => { column: :full_time_modifier, converter: Converters::BaseConverter },
    'length' => { column: :length, converter: Converters::BaseConverter }
  }.freeze

  PROGRAM_TYPES = %w[
    IHL
    NCD
    OJT
    FLGT
    CORR
  ].freeze

  validates :facility_code, :description, presence: true
  validates :program_type, inclusion: { in: PROGRAM_TYPES }
end
