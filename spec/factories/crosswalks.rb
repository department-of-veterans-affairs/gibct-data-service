# frozen_string_literal: true
FactoryGirl.define do
  factory :crosswalk do
    sequence :institution do |n|
      "institution #{n}"
    end

    facility_code { generate :facility_code }
    ope { generate :ope }
    cross { generate :cross }

    trait :institution_builder do
      facility_code 'ZZZZZZZZ'
      ope '99999999'
      cross '999999'
    end
  end
end
