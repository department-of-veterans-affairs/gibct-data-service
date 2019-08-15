# frozen_string_literal: true

FactoryGirl.define do
  factory :programs do
    facility_code { generate :facility_code }
    institution_name { 'NORTHEASTERN ILLINOIS UNIVERSITY' }
    program_type 'NCD'
    description 'COMPUTER SCIENCE'
    full_time_undergraduate '360'
    graduate '234'
    full_time_modifier 'S'
    length '1001'

    initialize_with do
      new(
        facility_code: facility_code,
        institution_name: institution_name,
        program_type: program_type,
        description: description,
        full_time_undergraduate: full_time_undergraduate,
        graduate: graduate,
        full_time_modifier: full_time_modifier,
        length: length
      )
    end
  end
end
