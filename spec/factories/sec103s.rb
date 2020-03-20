# frozen_string_literal: true

FactoryBot.define do
  factory :sec103 do
    facility_code { generate :facility_code }
    name { 'NORTHEASTERN ILLINOIS UNIVERSITY' }
    complies_with_sec_103 { true }
    solely_requires_coe { true }
    requires_coe_and_criteria { true }
  end
end
