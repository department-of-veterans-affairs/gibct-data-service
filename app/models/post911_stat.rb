# frozen_string_literal: true

class Post911Stat < ImportableRecord
  CSV_CONVERTER_INFO = {
    'facility_code' => { column: :facility_code, converter: Converters::FacilityCodeConverter },
    'distinct_count_of_tuition_and_fee' => { column: :tuition_and_fee_count, converter: Converters::NumberConverter },
    'tuition_and_fee_payments' => { column: :tuition_and_fee_payments, converter: Converters::NumberConverter },
    'tuition_and_fee_total_amount' => { column: :tuition_and_fee_total_amount, converter: Converters::NumberConverter },
    'distinct_count_of_yellow_ribbon' => { column: :yellow_ribbon_count, converter: Converters::NumberConverter },
    'yellow_ribbon_payments' => { column: :yellow_ribbon_payments, converter: Converters::NumberConverter },
    'yellow_ribbon_total_amount' => { column: :yellow_ribbon_total_amount, converter: Converters::NumberConverter }
  }.freeze

  validates :facility_code, presence: true
  validates :tuition_and_fee_count, numericality: { allow_blank: true }
  validates :tuition_and_fee_total_amount, numericality: { allow_blank: true }
  validates :yellow_ribbon_count, numericality: { allow_blank: true }
  validates :yellow_ribbon_total_amount, numericality: { allow_blank: true }
end
