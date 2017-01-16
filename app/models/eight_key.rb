# frozen_string_literal: true
class EightKey < ActiveRecord::Base
  include Loadable, Exportable

  MAP = {
    'institution of higher education' => { column: :institution, converter: InstitutionConverter },
    'city' => { column: :city, converter: BaseConverter },
    'state' => { column: :state, converter: StateConverter },
    'opeid' => { column: :ope, converter: OpeConverter },
    'ipeds_id' => { column: :cross, converter: CrossConverter },
    'notes' => { column: :notes, converter: BaseConverter }
  }.freeze

  validate :ope_or_cross
  before_validation :derive_dependent_columns

  # Ensure that the record is a legitimate eight_key row rather than embedded state headers or notes
  def ope_or_cross
    return if ope.present? || cross.present?

    errors.add(:ope, 'Ope cannot both be blank if cross (ipeds_id) is blank')
    errors.add(:cross, 'Cross (ipeds_id) cannot both be blank if ope is blank')
  end

  def derive_dependent_columns
    self.ope6 = Ope6Converter.convert(ope)
  end
end
