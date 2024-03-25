# frozen_string_literal: true

class Hcm < ImportableRecord
  CSV_CONVERTER_INFO = {
    'ope_id' => { column: :ope, converter: Converters::OpeConverter },
    'institution_name' => { column: :institution, converter: Converters::InstitutionConverter },
    'city' => { column: :city, converter: Converters::BaseConverter },
    'state' => { column: :state, converter: Converters::BaseConverter },
    'country' => { column: :country, converter: Converters::BaseConverter },
    'institution_type' => { column: :institution_type, converter: Converters::BaseConverter },
    'stop_pay/monitor_method' => { column: :hcm_type, converter: Converters::BaseConverter },
    'method_reason_desc' => { column: :hcm_reason, converter: Converters::BaseConverter }
  }.freeze

  validates :ope, :hcm_type, :hcm_reason, presence: true

  after_initialize :derive_dependent_columns

  def derive_dependent_columns
    self.ope6 = Converters::Ope6Converter.convert(ope)
  end
end
