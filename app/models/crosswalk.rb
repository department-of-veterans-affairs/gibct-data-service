# frozen_string_literal: true

class Crosswalk < ApplicationRecord

  COLS_USED_IN_INSTITUTION = %i[ope cross ope6].freeze

  CSV_CONVERTER_INFO = {
    'facility code' => { column: :facility_code, converter: FacilityCodeConverter },
    'institution name' => { column: :institution, converter: InstitutionConverter },
    'city' => { column: :city, converter: BaseConverter },
    'state' => { column: :state, converter: BaseConverter },
    'ipeds' => { column: :cross, converter: CrossConverter },
    'ope' => { column: :ope, converter: OpeConverter },
    'notes' => { column: :notes, converter: BaseConverter }
  }.freeze

  has_many :crosswalk_issue, dependent: :delete_all
  validates :facility_code, presence: true
  after_initialize :derive_dependent_columns

  def derive_dependent_columns
    self.ope6 = Ope6Converter.convert(ope)
  end
end
