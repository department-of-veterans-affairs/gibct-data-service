# frozen_string_literal: true

class InstitutionOwner < ImportableRecord
  COLS_USED_IN_INSTITUTION = %i[chief_officer ownership_name].freeze

  CSV_CONVERTER_INFO = {
    'facility_code' => { column: :facility_code, converter: Converters::FacilityCodeConverter },
    'institution_name' => { column: :institution_name, converter: Converters::InstitutionConverter },
    'chief_officer' => { column: :chief_officer, converter: Converters::BaseConverter },
    'ownership_name' => { column: :ownership_name, converter: Converters::BaseConverter }
  }.freeze

  validates :facility_code, :institution_name, presence: true
end
