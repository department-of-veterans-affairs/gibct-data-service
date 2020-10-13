# frozen_string_literal: true

class Vsoc < ApplicationRecord
  COLS_USED_IN_INSTITUTION = %i[vetsuccess_name vetsuccess_email].freeze

  CSV_CONVERTER_INFO = {
    'facility_code' => { column: :facility_code, converter: FacilityCodeConverter },
    'institution' => { column: :institution, converter: InstitutionConverter },
    'vetsuccess_name' => { column: :vetsuccess_name, converter: BaseConverter },
    'vetsuccess_email' => { column: :vetsuccess_email, converter: BaseConverter }
  }.freeze

  validates :facility_code, presence: true
end
