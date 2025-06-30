# frozen_string_literal: true

FactoryBot.define do
  factory :rate_adjustment do
    sequence(:benefit_type)
    rate { 3.20 }
  end
end