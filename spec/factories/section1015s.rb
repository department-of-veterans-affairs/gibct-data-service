# frozen_string_literal: true

FactoryBot.define do
  factory :section1015 do
    facility_code { generate :facility_code }
    institution { 'NORTHEASTERN ILLINOIS UNIVERSITY' }
    celo { 'y' }
  end
end
