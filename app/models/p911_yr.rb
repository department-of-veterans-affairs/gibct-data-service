# frozen_string_literal: true
class P911Yr < ActiveRecord::Base
  include CsvHelper

  COLS_USED_IN_INSTITUTION = [:p911_yr_recipients, :p911_yellow_ribbon].freeze

  CSV_CONVERTER_INFO = {
    'facility code' => { column: :facility_code, converter: FacilityCodeConverter },
    'name of institution' => { column: :institution, converter: InstitutionConverter },
    'state' => { column: :state, converter: BaseConverter },
    'country' => { column: :country, converter: BaseConverter },
    'number of trainees' => { column: :p911_yr_recipients, converter: NumberConverter },
    'profit status' => { column: :profit_status, converter: BaseConverter },
    'type of payment' => { column: :type_of_payment, converter: BaseConverter },
    'total cost' => { column: :p911_yellow_ribbon, converter: NumberConverter },
    'number of payments' => { column: :number_of_payments, converter: NumberConverter }
  }.freeze

  validates :facility_code, presence: true
  validates :p911_yr_recipients, numericality: true
  validates :p911_yellow_ribbon, numericality: true
end
