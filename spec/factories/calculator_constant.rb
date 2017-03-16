# frozen_string_literal: true
FactoryGirl.define do
  factory :calculator_constant do
    sequence(:id) { |n| n }
    sequence(:name) do
      length = [3, 6, 13].sample
      ('A'..'Z').to_a.sample(length).join
    end

    trait :string do
      string_value { |n| "String #{n}" }
    end

    trait :float do
      float_value { |_n| Random.rand.round(2) }
    end
  end
end
