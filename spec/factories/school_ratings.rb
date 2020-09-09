# frozen_string_literal: true

FactoryBot.define do
  factory :school_rating do
    facility_code { generate :facility_code }
    rater_id { '333333' }
    overall_experience { 1 }
    quality_of_classes { 1 }
    online_instruction { 1 }
    job_preparation { 1 }
    gi_bill_support { 1 }
    veteran_community { 1 }
    marketing_practices { 1 }
    rated_at { DateTime.parse('2020-01-01T12:05:02+08:00') }

    trait :institution_builder do
      facility_code { '1ZZZZZZZ' }
    end
  end
end
