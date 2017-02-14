# frozen_string_literal: true
class Hcm < ActiveRecord::Base
  include CsvHelper

  CSV_CONVERTER_INFO = {
    'ope id' => { column: :ope, converter: OpeConverter },
    'institution name' => { column: :institution, converter: InstitutionConverter },
    'city' => { column: :city, converter: BaseConverter },
    'state' => { column: :state, converter: BaseConverter },
    'country' => { column: :country, converter: BaseConverter },
    'institution type' => { column: :institution_type, converter: BaseConverter },
    'stop pay/monitor method' => { column: :hcm_type, converter: BaseConverter },
    'method reason desc' => { column: :hcm_reason, converter: BaseConverter }
  }.freeze

  validates :ope, :hcm_type, :hcm_reason, presence: true

  after_initialize :derive_dependent_columns

  def derive_dependent_columns
    self.ope6 = Ope6Converter.convert(ope)
    true
  end
end
