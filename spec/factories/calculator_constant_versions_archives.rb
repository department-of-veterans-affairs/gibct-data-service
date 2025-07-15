# frozen_string_literal: true

FactoryBot.define do
  factory :calculator_constant_versions_archive do
    transient do
      year { 2024 }
      date { Time.zone.local(year, 12, 31) }
    end

    association :version, factory: %i[version production]
    name { 'AVEGRADRATE' }
    float_value { 1.5 }
    description { 'MyString' }
    created_at { date }

    after(:build) do |archive, evaluator|
      archive.version.update(completed_at: evaluator.date)
    end
  end
end
