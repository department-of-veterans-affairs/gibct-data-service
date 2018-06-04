# frozen_string_literal: true
FactoryGirl.define do
  factory :yellow_ribbon_program_source do
    facility_code { generate :facility_code }

    degree_level 'Undergraduate'
    division_professional_school 'Non-Traditional'
    number_of_students 99_999
    contribution_amount 6000

    trait :institution_builder do
      facility_code '1ZZZZZZZ'
    end
  end
end
