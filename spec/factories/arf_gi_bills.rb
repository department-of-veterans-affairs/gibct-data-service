# frozen_string_literal: true

FactoryGirl.define do
  factory :arf_gi_bill do
    institution { 'SOME SCHOOL' }
    facility_code { generate :facility_code }

    sequence :gibill do |n|
      n
    end

    trait :institution_builder do
      facility_code '1ZZZZZZZ'
    end

    initialize_with do
      new(facility_code: facility_code, gibill: gibill)
    end
  end
end
