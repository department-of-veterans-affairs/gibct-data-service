# frozen_string_literal: true

class Post911Stat < ImportableRecord
  CSV_CONVERTER_INFO = {
    'facility code' => { column: :facility_code, converter: FacilityCodeConverter },
    'distinct count of tuition and fee' => { column: :tuition_and_fee_count, converter: NumberConverter },
    'tuition and fee payments' => { column: :tuition_and_fee_payments, converter: NumberConverter },
    'tuition and fee total amount' => { column: :tuition_and_fee_total_amount, converter: NumberConverter },
    'distinct count of yellow ribbon' => { column: :yellow_ribbon_count, converter: NumberConverter },
    'yellow ribbon payments' => { column: :yellow_ribbon_payments, converter: NumberConverter },
    'yellow ribbon total amount' => { column: :yellow_ribbon_total_amount, converter: NumberConverter }
  }.freeze

  validates :facility_code, presence: true
  validates :tuition_and_fee_count, numericality: { allow_blank: true }
  validates :tuition_and_fee_total_amount, numericality: { allow_blank: true }
  validates :yellow_ribbon_count, numericality: { allow_blank: true }
  validates :yellow_ribbon_total_amount, numericality: { allow_blank: true }
end
