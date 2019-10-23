# frozen_string_literal: true

FactoryBot.define do
  factory :sec702 do
    sequence :state do |n|
      StateConverter::STATES.keys[(n - 1) % StateConverter::STATES.length]
    end

    sec_702 { false }

    trait :institution_builder do
      state { 'NY' }
    end

    initialize_with do
      new(state: state, sec_702: sec_702)
    end
  end
end
