# frozen_string_literal: true
FactoryGirl.define do
  factory :settlement do
    institution { 'Some School' }
    cross { generate :cross }

    settlement_description { 'Settlement with U.S. Government' }

    trait :institution_builder do
      cross '999999'
    end
  end
end
