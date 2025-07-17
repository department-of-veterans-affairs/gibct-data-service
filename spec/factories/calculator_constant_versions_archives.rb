# frozen_string_literal: true

FactoryBot.define do
  factory :calculator_constant_versions_archive do
    transient do
      year { 2024 }
      date { Time.current.change(year: year) }
    end

    sequence(:name) { |n| "CONSTANT #{ENV['TEST_ENV_NUMBER'].to_i * 1000 + n}" }
    float_value { 1.5 }
    description { 'MyString' }
    created_at { date }
    # Override version if you want to create multiple constants belonging to same version
    version { nil }

    after(:build) do |archive, evaluator|
      archive.version ||= create(:version, :production, :from_year, year: evaluator.year)
    end
  end
end
