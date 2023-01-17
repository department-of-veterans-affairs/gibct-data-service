# frozen_string_literal: true

# delete me before pull request

FactoryBot.define do
  factory :school_rating do
    sequence(:rater_id) do |n|
      "rater_#{n}"
    end
    facility_code { generate :facility_code }
    rated_at { DateTime.parse('2020-01-01T12:05:02+08:00') }

    trait :ihl_facility_code do
      facility_code { '11000000' }
    end

    trait :next_day do
      rated_at { DateTime.parse('2020-02-01T12:05:02+08:00') }
    end

    trait :quality_of_classes_only do
      overall_experience { nil }
      quality_of_classes { 5 }
      gi_bill_support { nil }
      veteran_community { nil }
    end

    trait :gi_bill_support_only do
      overall_experience { nil }
      quality_of_classes { nil }
      gi_bill_support { 5 }
      veteran_community { nil }
    end

    trait :all_threes do
      overall_experience { 3 }
      gi_bill_support { 3 }
      veteran_community { 3 }
      quality_of_classes { 3 }
    end
  end
end
