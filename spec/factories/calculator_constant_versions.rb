# frozen_string_literal: true

FactoryBot.define do
  factory :calculator_constant_version do
    association :version, factory: %i[version production]
    name { 'AVGDODBAH' }
    float_value { 1000.00 }
    description { 'Average DOD BAH' }
  end
end
