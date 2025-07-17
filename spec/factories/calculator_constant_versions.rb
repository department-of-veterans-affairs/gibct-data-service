# frozen_string_literal: true

FactoryBot.define do
  factory :calculator_constant_version do
    association :version, factory: %i[version production]
    sequence(:name) { |n| "CONSTANT #{ENV['TEST_ENV_NUMBER'].to_i * 1000 + n}" }
    float_value { 1000.00 }
    description { 'Average DOD BAH' }
  end
end
