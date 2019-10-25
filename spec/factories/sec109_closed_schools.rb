# frozen_string_literal: true

FactoryBot.define do
  factory :sec109_closed_school do
    facility_code { generate :facility_code }

    school_name { 'College of Charleston' }
    closure109 { false }

    trait :institution_builder do
      facility_code { '1ZZZZZZZ' }
    end

    initialize_with do
      new(
        facility_code: facility_code, school_name: school_name,
        closure109: closure109
      )
    end
  end
end
