# frozen_string_literal: true

FactoryBot.define do
  factory :rate_adjustment do
    benefit_type { 33 }
    rate { 3.20 }
  end
end
