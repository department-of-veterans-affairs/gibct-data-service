# frozen_string_literal: true

FactoryBot.define do
  factory :calculator_constant do
    sequence(:name) do
      length = [3, 6, 13].sample
      ('A'..'Z').to_a.sample(length).join
    end
    float_value { |_n| Random.rand.round(2) }
  end

  trait :avg_dod_bah_constant do
    name { 'AVGDODBAH' }
    float_value {1000.00}
  end

end
