# frozen_string_literal: true

class Program < ApplicationRecord
  include CsvHelper

  CSV_CONVERTER_INFO = {
    'facility code' => { column: :facility_code, converter: FacilityCodeConverter },
    'institution name' => { column: :institution_name, converter: InstitutionConverter },
    'program type' => { column: :program_type, converter: BaseConverter },
    'description' => { column: :description, converter: BaseConverter },
    'full time undergraduate' => { column: :full_time_undergraduate, converter: BaseConverter },
    'graduate' => { column: :graduate, converter: BaseConverter },
    'full time modifier' => { column: :full_time_modifier, converter: BaseConverter },
    'length' => { column: :length, converter: BaseConverter }
  }.freeze

  validates :facility_code, presence: true
<<<<<<< HEAD
  validates :program_type, inclusion: { in: InstitutionProgram::PROGRAM_TYPES }
=======
  validates_with ProgramValidator, on: :after_import
>>>>>>> 66246f479da7fc0a1a3ceb50da26f9948e0f935c
end
