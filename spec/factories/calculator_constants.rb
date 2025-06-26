# frozen_string_literal: true

FactoryBot.define do
  factory :calculator_constant do
    sequence(:name) do |n|
      # Only generate FISCALYEAR via :year trait
      names = CalculatorConstant::CONSTANT_NAMES.dup.reject { |name| name == 'FISCALYEAR' }
      raise 'Number of factories exceeds available calculator constant names' if n >= names.size

      names[n]
    end
    float_value { (Random.rand * 1_000).round(2) }
    description { 'Sample description' }

    trait :associated_rate_adjustment do
      association :rate_adjustment
    end

    trait :year do
      name { 'FISCALYEAR' }
    end
  end
end
