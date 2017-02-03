# frozen_string_literal: true
FactoryGirl.define do
  factory :p911_tf do
    institution { 'SOME SCHOOL' }
    facility_code { generate :facility_code }
    p911_tuition_fees { 1 }
    p911_recipients { 1 }

    trait :institution_builder do
      facility_code 'ZZZZZZZZ'
    end
  end
end
