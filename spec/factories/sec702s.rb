# frozen_string_literal: true
FactoryGirl.define do
  factory :sec702 do
    sequence :state do |n|
      StateConverter::STATES.keys[(n - 1) % StateConverter::STATES.length]
    end

    sequence :state_full_name do |n|
      StateConverter::STATES.values[(n - 1) % StateConverter::STATES.length]
    end

    sec_702 true

    trait :institution_builder do
    end
  end
end
