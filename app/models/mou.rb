# frozen_string_literal: true
class Mou < ActiveRecord::Base
  include Loadable, Exportable

  STATUSES = ['probation - dod', 'title iv non-compliant'].freeze

  MAP = {
    'ope id' => { column: :ope, converter: OpeConverter },
    'institution name' => { column: :institution, converter: BaseConverter },
    'trade name' => { column: :trade_name, converter: BaseConverter },
    'city' => { column: :city, converter: BaseConverter },
    'state' => { column: :state, converter: BaseConverter },
    'institution type' => { column: :institution_type, converter: BaseConverter },
    'status' => { column: :status, converter: BaseConverter },
    'approval date' => { column: :approval_date, converter: BaseConverter }
  }.freeze

  validates :ope, :ope6, presence: true

  before_validation :derive_dependent_columns

  def derive_dependent_columns
    self.dodmou = to_dodmou
    self.dod_status = to_dod_status
    self.ope6 = Ope6Converter.convert(ope)

    true
  end

  def to_dodmou
    STATUSES.include?(status)
  end

  def to_dod_status
    (status =~ /dod/).present?
  end
end
