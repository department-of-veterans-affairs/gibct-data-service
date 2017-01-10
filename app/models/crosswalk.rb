# frozen_string_literal: true
class Crosswalk < ActiveRecord::Base
  include Loadable, Exportable

  before_validation :derive_dependent_columns

  MAP = {
    'facility code' => { facility_code: FacilityCodeConverter },
    'institution name' => { institution: InstitutionConverter },
    'city' => { city: BaseConverter },
    'state' => { state: BaseConverter },
    'ipeds' => { cross: CrossConverter },
    'ope' => { ope: OpeConverter },
    'notes' => { notes: BaseConverter }
  }.freeze

  validates :facility_code, :institution, :ope, :cross, presence: true

  def derive_dependent_columns
    self.ope6 = Ope6Converter.convert(ope)

    true
  end
end
