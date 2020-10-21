# frozen_string_literal: true

class Hcm < ImportableRecord
  CSV_CONVERTER_INFO = {
    'ope_id' => { column: :ope, converter: OpeConverter },
    'institution_name' => { column: :institution, converter: InstitutionConverter },
    'city' => { column: :city, converter: BaseConverter },
    'state' => { column: :state, converter: BaseConverter },
    'country' => { column: :country, converter: BaseConverter },
    'institution_type' => { column: :institution_type, converter: BaseConverter },
    'stop_pay/monitor_method' => { column: :hcm_type, converter: BaseConverter },
    'method_reason_desc' => { column: :hcm_reason, converter: BaseConverter }
  }.freeze

  validates :ope, :hcm_type, :hcm_reason, presence: true

  after_initialize :derive_dependent_columns

  def derive_dependent_columns
    self.ope6 = Ope6Converter.convert(ope)
  end
end
