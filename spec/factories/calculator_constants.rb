# frozen_string_literal: true

FactoryBot.define do
  factory :calculator_constant do
    name { CalculatorConstant::CONSTANT_NAMES.sample }
    float_value { (Random.rand * 1_000).round(2) }
    description { 'Sample description' }

    trait :associated_rate_adjustment do
      association :rate_adjustment
    end
  end
end
