# frozen_string_literal: true

class EightKey < ActiveRecord::Base
  include CsvHelper

  CSV_CONVERTER_INFO = {
    'institution of higher education' => { column: :institution, converter: InstitutionConverter },
    'city' => { column: :city, converter: BaseConverter },
    'state' => { column: :state, converter: BaseConverter },
    'opeid' => { column: :ope, converter: OpeConverter },
    'ipeds id' => { column: :cross, converter: CrossConverter },
    'notes' => { column: :notes, converter: BaseConverter }
  }.freeze

  validate :ope_or_cross
  after_initialize :derive_dependent_columns

  # Ensure that the record is a legitimate eight_key row rather than embedded state headers or notes
  def ope_or_cross
    return if ope.present? || cross.present?

    msg = institution.present? ? "Institution '#{institution}' " : 'Institution '
    msg += 'must have either an Ope or an Ipeds id, or both'

    errors.add(:ope_and_cross, msg)
    # errors.add(:cross, msg)
  end

  def derive_dependent_columns
    self.ope6 = Ope6Converter.convert(ope)
  end
end
