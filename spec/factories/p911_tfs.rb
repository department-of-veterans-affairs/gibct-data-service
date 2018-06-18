# frozen_string_literal: true

FactoryGirl.define do
  factory :p911_tf do
    facility_code { generate :facility_code }
    p911_tuition_fees { 1 }
    p911_recipients { 1 }

    trait :institution_builder do
      facility_code '1ZZZZZZZ'
    end

    initialize_with do
      new(
        facility_code: facility_code, p911_tuition_fees: p911_tuition_fees,
        p911_recipients: p911_recipients
      )
    end
  end
end
