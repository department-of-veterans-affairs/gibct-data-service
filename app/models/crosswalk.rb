# frozen_string_literal: true
class Crosswalk < ActiveRecord::Base
  include Loadable, Exportable

  before_validation :derive_dependent_columns

  MAP = {
    'facility code' => { column: :facility_code, converter: FacilityCodeConverter },
    'institution name' => { column: :institution, converter: InstitutionConverter },
    'city' => { column: :city, converter: BaseConverter },
    'state' => { column: :state, converter: BaseConverter },
    'ipeds' => { column: :cross, converter: CrossConverter },
    'ope' => { column: :ope, converter: OpeConverter },
    'notes' => { column: :notes, converter: BaseConverter }
  }.freeze

  # DataCsv uses columns :facility_code, :cross, and :ope6
  validates :facility_code, presence: true

  def derive_dependent_columns
    self.ope6 = Ope6Converter.convert(ope)

    true
  end
end
