# frozen_string_literal: true

class Crosswalk < ImportableRecord
  COLS_USED_IN_INSTITUTION = %i[ope cross ope6].freeze

  CSV_CONVERTER_INFO = {
    'facility_code' => { column: :facility_code, converter: Converters::FacilityCodeConverter },
    'institution_name' => { column: :institution, converter: Converters::InstitutionConverter },
    'city' => { column: :city, converter: Converters::BaseConverter },
    'state' => { column: :state, converter: Converters::BaseConverter },
    'ipeds' => { column: :cross, converter: Converters::CrossConverter },
    'ope' => { column: :ope, converter: Converters::OpeConverter },
    'notes' => { column: :notes, converter: Converters::BaseConverter }
  }.freeze

  has_many :crosswalk_issue, dependent: :delete_all
  validates :facility_code, presence: true
  after_initialize :derive_dependent_columns

  # Instance methods
  def derive_dependent_columns
    self.ope6 = Converters::Ope6Converter.convert(ope)
  end
end
