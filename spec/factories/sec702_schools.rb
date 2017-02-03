# frozen_string_literal: true
FactoryGirl.define do
  factory :sec702_school do
    facility_code { generate :facility_code }
    sec_702 true

    trait :institution_builder do
      facility_code 'ZZZZZZZZ'
    end
  end
end
