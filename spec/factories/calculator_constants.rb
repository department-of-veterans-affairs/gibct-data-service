# frozen_string_literal: true

FactoryBot.define do
  factory :calculator_constant do
    sequence(:name) { |n| "CONSTANT #{n}" }
    float_value { (Random.rand * 1_000).round(2) }
    description { 'Sample description' }

    trait :associated_rate_adjustment do
      association :rate_adjustment
    end
  end
end
