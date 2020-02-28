# frozen_string_literal: true

FactoryBot.define do
  factory :yellow_ribbon_program do
    association :institution, factory: :institution

    city { 'Boulder' }
    contribution_amount { 6_000 }
    degree_level { 'Undergraduate' }
    division_professional_school { 'Non-Traditional' }
    facility_code { generate :facility_code }
    number_of_students { 99_999 }
    school_name_in_yr_database { 'University' }
    state { 'CO' }
    street_address { '1234 University Drive' }
    version { 1 }
    zip { '80303' }

    trait :institution_builder do
      facility_code { '1ZZZZZZZ' }
    end

    trait :in_florence do
      city { 'Florence' }
      school_name_in_yr_database { 'Future Tech University' }
      number_of_students { 1 }
      state { 'KY' }
      zip { '41042' }
    end
  end
end
