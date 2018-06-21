# frozen_string_literal: true

FactoryGirl.define do
  factory :sec702_school do
    facility_code { generate :facility_code }
    sec_702 false

    trait :institution_builder do
      facility_code '1ZZZZZZZ'
    end

    initialize_with do
      new(facility_code: facility_code, sec_702: sec_702)
    end
  end
end
