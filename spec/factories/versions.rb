# frozen_string_literal: true
FactoryGirl.define do
  factory :version do
    sequence :number do |n|
      n
    end

    sequence :by do |n|
      "user#{n}@va.gov"
    end

    trait :as_production do
      approved_on Time.zone.now.to_datetime
    end
  end
end
