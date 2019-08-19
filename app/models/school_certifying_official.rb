# frozen_string_literal: true

class SchoolCertifyingOfficial < ActiveRecord::Base
  include CsvHelper

  CSV_CONVERTER_INFO = {
    'facility_code' => { column: :facility_code, converter: FacilityCodeConverter },
    'institution_name' => { column: :institution_name, converter: InstitutionConverter },
    'priority' => { column: :priority, converter: BaseConverter },
    'first_name' => { column: :first_name, converter: BaseConverter },
    'last_name' => { column: :last_name, converter: BaseConverter },
    'title' => { column: :title, converter: BaseConverter },
    'phone_area_code' => { column: :phone_area_code, converter: BaseConverter },
    'phone_number' => { column: :phone_number, converter: BaseConverter },
    'phone_extension' => { column: :phone_extension, converter: BaseConverter },
    'email' => { column: :email, converter: BaseConverter }
  }.freeze

  validates :facility_code, presence: true
end
