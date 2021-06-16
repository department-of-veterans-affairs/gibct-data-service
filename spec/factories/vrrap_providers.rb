# frozen_string_literal: true

FactoryBot.define do
  factory :vrrap_provider do
    facility_code { generate :facility_code }
    vaoc { true }
  end
end
