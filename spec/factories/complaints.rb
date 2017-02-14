# frozen_string_literal: true
FactoryGirl.define do
  factory :complaint do
    facility_code { generate :facility_code }
    ope { generate :ope }

    status 'closed'
    closed_reason 'resolved'
    issues nil

    trait :institution_builder do
      facility_code '1ZZZZZZZ'
      ope '99999999'
    end

    initialize_with do
      new(
        facility_code: facility_code, ope: ope, status: status,
        closed_reason: closed_reason, issues: issues
      )
    end
  end
end
