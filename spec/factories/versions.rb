# frozen_string_literal: true
FactoryGirl.define do
  factory :version do
    user

    sequence :version do |n|
      n
    end

    trait :production do
      production true
    end
  end
end
