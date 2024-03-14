# frozen_string_literal: true

FactoryBot.define do
  factory :institution_owner do
    facility_code { generate :facility_code }
    institution_name { 'Podunk U' }
    chief_officer { 'Hakon James' }
    ownership_name { 'Podunk U' }
  end
end
