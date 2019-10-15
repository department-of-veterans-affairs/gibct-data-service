# frozen_string_literal: true

FactoryBot.define do
  factory :p911_yr do
    facility_code { generate :facility_code }
    p911_yellow_ribbon { 1 }
    p911_yr_recipients { 1 }

    trait :institution_builder do
      facility_code { '1ZZZZZZZ' }
    end

    initialize_with do
      new(
        facility_code: facility_code, p911_yellow_ribbon: p911_yellow_ribbon,
        p911_yr_recipients: p911_yr_recipients
      )
    end
  end
end
