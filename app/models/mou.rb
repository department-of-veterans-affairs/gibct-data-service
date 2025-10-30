# frozen_string_literal: true

class Mou < ImportableRecord
  STATUSES = /\A(probation - dod|title iv non-compliant)\z/i

  CSV_CONVERTER_INFO = {
    'opeid' => { column: :ope, converter: Converters::OpeConverter },
    'name' => { column: :institution, converter: Converters::InstitutionConverter },
    'trade_name' => { column: :trade_name, converter: Converters::BaseConverter },
    'city' => { column: :city, converter: Converters::BaseConverter },
    'state' => { column: :state, converter: Converters::BaseConverter },
    'type' => { column: :institution_type, converter: Converters::BaseConverter },
    'status' => { column: :status, converter: Converters::BaseConverter },
    'approval_date' => { column: :approval_date, converter: Converters::BaseConverter }
  }.freeze

  validates :ope, :ope6, presence: true

  after_initialize :derive_dependent_columns

  def derive_dependent_columns
    self.dodmou = to_dodmou
    self.dod_status = to_dod_status
    self.ope6 = Converters::Ope6Converter.convert(ope)
  end

  def to_dodmou
    status.blank? || (status.present? && !status.match?(STATUSES))
  end

  def to_dod_status
    status.present? && status.match?(/dod/i)
  end
end
