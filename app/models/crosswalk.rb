# frozen_string_literal: true
class Crosswalk < ActiveRecord::Base
  include Loadable, Exportable

  MAP = {
    'facility code' => { facility_code: FacilityCodeConverter },
    'institution name' => { institution: InstitutionConverter },
    'city' => { city: BaseConverter },
    'state' => { state: StateConverter },
    'ipeds' => { cross: CrossConverter },
    'ope' => { ope: OpeConverter },
    'notes' => { notes: BaseConverter }
  }.freeze

  validates :facility_code, presence: true
  validates :institution, presence: true
end
