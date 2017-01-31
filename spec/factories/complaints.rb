# frozen_string_literal: true
FactoryGirl.define do
  factory :complaint do
    facility_code { generate :facility_code }
    ope { generate :ope }

    status 'closed'
    closed_reason 'resolved'
  end
end
