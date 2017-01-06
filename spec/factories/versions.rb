# frozen_string_literal: true
FactoryGirl.define do
  factory :version do
    user

    trait :production do
      production true
    end
  end
end
