# frozen_string_literal: true

class SchoolCertifyingOfficial < ImportableRecord
  VALID_PRIORITY_VALUES = %w[
    PRIMARY
    SECONDARY
  ].freeze

  CSV_CONVERTER_INFO = {
    'facility_code' => { column: :facility_code, converter: Converters::FacilityCodeConverter },
    'institution_name' => { column: :institution_name, converter: Converters::InstitutionConverter },
    'priority' => { column: :priority, converter: Converters::BaseConverter },
    'first_name' => { column: :first_name, converter: Converters::BaseConverter },
    'last_name' => { column: :last_name, converter: Converters::BaseConverter },
    'title' => { column: :title, converter: Converters::BaseConverter },
    'phone_area_code' => { column: :phone_area_code, converter: Converters::BaseConverter },
    'phone_number' => { column: :phone_number, converter: Converters::BaseConverter },
    'phone_extension' => { column: :phone_extension, converter: Converters::BaseConverter },
    'email' => { column: :email, converter: Converters::BaseConverter }
  }.freeze

  validates :facility_code, presence: true
  validates_with SchoolCertifyingOfficialValidator, on: :after_import
end
