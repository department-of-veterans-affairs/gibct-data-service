# frozen_string_literal: true
class Settlement < ActiveRecord::Base
  include CsvHelper

  CSV_CONVERTER_INFO = {
    'unitid' => { column: :cross, converter: CrossConverter },
    'instnm' => { column: :institution, converter: InstitutionConverter },
    'school_system_code' => { column: :school_system_code, converter: NumberConverter },
    'school_system_name' => { column: :school_system_name, converter: BaseConverter },
    'settlement_description' => { column: :settlement_description, converter: BaseConverter },
    'settlement_date' => { column: :settlement_date, converter: BaseConverter },
    'settlement_link' => { column: :settlement_link, converter: BaseConverter }
  }.freeze

  validates :cross, :settlement_description, presence: true
end
