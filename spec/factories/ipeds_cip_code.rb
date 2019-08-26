# frozen_string_literal: true

FactoryBot.define do
  factory :ipeds_cip_code do
    cross { generate :cross }
    cipcode 1.0901 # Animal Sciences, General
    ctotalt 5

    trait :institution_builder do
      cross '999999'
    end
  end
end
