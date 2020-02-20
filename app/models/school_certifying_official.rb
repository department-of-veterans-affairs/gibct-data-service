# frozen_string_literal: true

class SchoolCertifyingOfficial < ApplicationRecord
  include CsvHelper

  belongs_to :institution

  self.ignored_columns = ['institution_id']

  CSV_CONVERTER_INFO = {
    'facility code' => { column: :facility_code, converter: FacilityCodeConverter },
    'institution name' => { column: :institution_name, converter: InstitutionConverter },
    'priority' => { column: :priority, converter: BaseConverter },
    'first name' => { column: :first_name, converter: BaseConverter },
    'last name' => { column: :last_name, converter: BaseConverter },
    'title' => { column: :title, converter: BaseConverter },
    'phone - area code' => { column: :phone_area_code, converter: BaseConverter },
    'phone - number' => { column: :phone_number, converter: BaseConverter },
    'phone - extension' => { column: :phone_extension, converter: BaseConverter },
    'email' => { column: :email, converter: BaseConverter }
  }.freeze

  validates :facility_code, presence: true
end
