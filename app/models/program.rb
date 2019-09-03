# frozen_string_literal: true

class Program < ActiveRecord::Base
  include CsvHelper

  CSV_CONVERTER_INFO = {
    'facility_code' => { column: :facility_code, converter: FacilityCodeConverter },
    'institution_name' => { column: :institution_name, converter: InstitutionConverter },
    'program_type' => { column: :program_type, converter: BaseConverter },
    'description' => { column: :description, converter: BaseConverter },
    'full_time_undergraduate' => { column: :full_time_undergraduate, converter: BaseConverter },
    'graduate' => { column: :graduate, converter: BaseConverter },
    'full_time_modifier' => { column: :full_time_modifier, converter: BaseConverter },
    'length' => { column: :length, converter: BaseConverter }
  }.freeze

  validates :facility_code, presence: true

end
