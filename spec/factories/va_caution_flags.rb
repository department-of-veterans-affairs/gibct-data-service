# frozen_string_literal: true

FactoryBot.define do
  factory :va_caution_flag do
    facility_code { generate :facility_code }
    sequence(:institution_name, 1000) { |n| "institution_name #{n}" }
    sequence(:school_system_name, 1000) { |n| "school_system_name #{n}" }

    trait :settlement do
      settlement_title { 'settlement_title' }
      settlement_description { 'settlement_description' }
      settlement_date { '01/20/2021' }
      settlement_link { 'https://va.gov' }
    end

    trait :school_closing do
      school_closing_date { '02/20/2020' }
    end

    trait :not_sec_702 do
      sec_702 { false }
    end
  end
end
