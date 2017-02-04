# frozen_string_literal: true
class Vsoc < ActiveRecord::Base
  include Loadable, Exportable

  USE_COLUMNS = [:vetsuccess_name, :vetsuccess_email].freeze

  MAP = {
    'facility_code' => { column: :facility_code, converter: FacilityCodeConverter },
    'institution' => { column: :institution, converter: InstitutionConverter },
    'vetsuccess_name' => { column: :vetsuccess_name, converter: BaseConverter },
    'vetsuccess_email' => { column: :vetsuccess_email, converter: BaseConverter }
  }.freeze

  validates :facility_code, presence: true
end
