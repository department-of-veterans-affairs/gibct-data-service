# frozen_string_literal: true
FactoryGirl.define do
  factory :complaint do
    facility_code { generate :facility_code }
    ope { generate :ope }

    status 'closed'
    closed_reason 'resolved'

    trait :institution_builder do
      facility_code 'ZZZZZZZZ'
      ope '99999999'
    end
  end
end
