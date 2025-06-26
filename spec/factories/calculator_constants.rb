# frozen_string_literal: true

FactoryBot.define do
  factory :calculator_constant do
    sequence(:name) do |n|
      names = CalculatorConstant::CONSTANT_NAMES
      raise "Number of factories exceeds available calculator constant names" if n >= names.size
      names[n]
    end
    float_value { (Random.rand * 1_000).round(2) }
    description { 'Sample description' }

    trait :associated_rate_adjustment do
      association :rate_adjustment
    end
  end
end
