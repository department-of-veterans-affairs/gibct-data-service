# frozen_string_literal: true
FactoryGirl.define do
  factory :calculator_constant do
    sequence(:name) do
      length = [3, 6, 13].sample
      ('A'..'Z').to_a.sample(length).join
    end

    float_value { |_n| Random.rand.round(2) }
    string_value nil

    trait :string do
      string_value { |n| "String #{n}" }
      float_value nil
    end
  end
end
