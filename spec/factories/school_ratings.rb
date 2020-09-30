# frozen_string_literal: true

FactoryBot.define do
  factory :school_rating do
    facility_code { generate :facility_code }
    rater_id { generate :rater_id }
    rated_at { DateTime.parse('2020-01-01T12:05:02+08:00') }

    trait :ihl_facility_code do
      facility_code { '11000000' }
    end

    trait :next_day do
      rated_at { DateTime.parse('2020-02-01T12:05:02+08:00') }
    end

    trait :online_instruction_only do
      overall_experience { nil }
      quality_of_classes { nil }
      online_instruction { 5 }
      job_preparation { nil }
      gi_bill_support { nil }
      veteran_community { nil }
      marketing_practices { nil }
    end

    trait :all_threes do
      overall_experience { 3 }
      quality_of_classes { 3 }
      online_instruction { 3 }
      job_preparation { 3 }
      gi_bill_support { 3 }
      veteran_community { 3 }
      marketing_practices { 3 }
    end
  end
end
