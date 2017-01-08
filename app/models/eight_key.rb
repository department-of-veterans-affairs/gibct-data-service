# frozen_string_literal: true
class EightKey < ActiveRecord::Base
  include Loadable, Exportable

  validate :validate_ope_and_cross

  MAP = {
    'institution of higher education' => { institution: InstitutionConverter },
    'city' => { city: BaseConverter },
    'state' => { state: StateConverter },
    'opeid' => { ope: OpeConverter },
    'ipeds_id' => { cross: CrossConverter },
    'notes' => { notes: BaseConverter }
  }.freeze

  def validate_ope_and_cross
    return if ope.present? || cross.present?

    errors.add(:ope, 'opeid and ipeds id cannot both be blank')
    errors.add(:cross, 'opeid and ipeds id cannot both be blank')
  end
end
