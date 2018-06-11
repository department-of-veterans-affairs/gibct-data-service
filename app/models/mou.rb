# frozen_string_literal: true

class Mou < ActiveRecord::Base
  include CsvHelper

  STATUSES = /\A(probation - dod|title iv non-compliant)\z/i

  CSV_CONVERTER_INFO = {
    'ope id' => { column: :ope, converter: OpeConverter },
    'institution name' => { column: :institution, converter: InstitutionConverter },
    'trade name' => { column: :trade_name, converter: BaseConverter },
    'city' => { column: :city, converter: BaseConverter },
    'state' => { column: :state, converter: BaseConverter },
    'institution type' => { column: :institution_type, converter: BaseConverter },
    'status' => { column: :status, converter: BaseConverter },
    'approval date' => { column: :approval_date, converter: BaseConverter }
  }.freeze

  validates :ope, :ope6, presence: true

  after_initialize :derive_dependent_columns

  def derive_dependent_columns
    self.dodmou = to_dodmou
    self.dod_status = to_dod_status
    self.ope6 = Ope6Converter.convert(ope)
  end

  def to_dodmou
    (status =~ STATUSES).nil?
  end

  def to_dod_status
    (status =~ /dod/i).present?
  end
end
