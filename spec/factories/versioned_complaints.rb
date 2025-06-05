# frozen_string_literal: true

FactoryBot.define do
  factory :versioned_complaint do
    version
    facility_code { generate :facility_code }
    ope { generate :ope }
    closed { '2024-01-01' }

    status { 'closed' }
    closed_reason { 'resolved' }
    issues { nil }
  end
end
