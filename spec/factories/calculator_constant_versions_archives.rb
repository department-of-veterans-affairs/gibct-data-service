# frozen_string_literal: true

FactoryBot.define do
  factory :calculator_constant_versions_archive do
    version_id { '' }
    name { 'AVEGRADRATE' }
    float_value { 1.5 }
    description { 'MyString' }
  end
end
