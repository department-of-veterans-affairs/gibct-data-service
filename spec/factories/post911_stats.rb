# frozen_string_literal: true

FactoryBot.define do
  factory :post911_stat do
    facility_code { generate :facility_code }
    tuition_and_fee_count { 1 }
    tuition_and_fee_total_amount { 1 }
    yellow_ribbon_count { 1 }
    yellow_ribbon_total_amount { 1 }

    trait :institution_builder do
      facility_code { '1ZZZZZZZ' }
    end

    initialize_with do
      new(
        facility_code: facility_code,
        tuition_and_fee_count: tuition_and_fee_count,
        tuition_and_fee_total_amount: tuition_and_fee_total_amount,
        yellow_ribbon_count: yellow_ribbon_count,
        yellow_ribbon_total_amount: yellow_ribbon_total_amount
      )
    end
  end
end
