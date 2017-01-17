# frozen_string_literal: true
FactoryGirl.define do
  factory :sec702 do
    sequence :state do |n|
      StateConverter::STATES.keys[n - 1]
    end

    sequence :state_full_name do |n|
      StateConverter::STATES.values[n - 1]
    end

    sec_702 true
  end
end
