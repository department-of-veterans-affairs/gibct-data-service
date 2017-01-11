# frozen_string_literal: true
class EightKey < ActiveRecord::Base
  include Loadable, Exportable

  validate :validate_ope_and_cross

  MAP = {
    'institution of higher education' => { column: :institution, converter: InstitutionConverter },
    'city' => { column: :city, converter: BaseConverter },
    'state' => { column: :state, converter: StateConverter },
    'opeid' => { column: :ope, converter: OpeConverter },
    'ipeds_id' => { column: :cross, converter: CrossConverter },
    'notes' => { column: :notes, converter: BaseConverter }
  }.freeze

  def validate_ope_and_cross
    return if ope.present? || cross.present?

    errors.add(:ope, 'opeid and ipeds id cannot both be blank')
    errors.add(:cross, 'opeid and ipeds id cannot both be blank')
  end
end
