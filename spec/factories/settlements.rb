# frozen_string_literal: true

FactoryBot.define do
  factory :settlement do
    cross { generate :cross }

    settlement_description { 'Settlement with U.S. Government' }

    trait :institution_builder do
      cross { '999999' }
    end

    trait :matches_by_facility_code do
      cross { '1ZZZZZZZ' }
    end

    initialize_with do
      new(cross: cross, settlement_description: settlement_description)
    end
  end
end
