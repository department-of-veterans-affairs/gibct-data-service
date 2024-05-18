# frozen_string_literal: true

class EightKey < ImportableRecord
  CSV_CONVERTER_INFO = {
    'institution_of_higher_education' => { column: :institution, converter: Converters::InstitutionConverter },
    'city' => { column: :city, converter: Converters::BaseConverter },
    'state' => { column: :state, converter: Converters::BaseConverter },
    'opeid' => { column: :ope, converter: Converters::OpeConverter },
    'ipedsid' => { column: :cross, converter: Converters::CrossConverter },
    'notes' => { column: :notes, converter: Converters::BaseConverter }
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
    self.ope6 = Converters::Ope6Converter.convert(ope)
  end
end
