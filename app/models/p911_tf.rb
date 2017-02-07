# frozen_string_literal: true
class P911Tf < ActiveRecord::Base
  include Loadable, Exportable

  USE_COLUMNS = [:p911_recipients, :p911_tuition_fees].freeze

  MAP = {
    'facility code' => { column: :facility_code, converter: FacilityCodeConverter },
    'name of institution' => { column: :institution, converter: InstitutionConverter },
    'state' => { column: :state, converter: BaseConverter },
    'country' => { column: :country, converter: BaseConverter },
    'number of trainees' => { column: :p911_recipients, converter: BaseConverter },
    'profit status' => { column: :profit_status, converter: BaseConverter },
    'type of payment' => { column: :type_of_payment, converter: BaseConverter },
    'tuition and fees cost' => { column: :p911_tuition_fees, converter: CurrencyConverter },
    'number of payments' => { column: :number_of_payments, converter: BaseConverter }
  }.freeze

  validates :facility_code, presence: true
  validates :p911_recipients, numericality: true
  validates :p911_tuition_fees, numericality: true
end
