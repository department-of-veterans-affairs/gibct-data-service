# frozen_string_literal: true

FactoryGirl.define do
  factory :settlement do
    cross { generate :cross }

    settlement_description { 'Settlement with U.S. Government' }

    trait :institution_builder do
      cross '999999'
    end

    initialize_with do
      new(cross: cross, settlement_description: settlement_description)
    end
  end
end
