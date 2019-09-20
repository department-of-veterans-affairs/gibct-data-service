# frozen_string_literal: true

FactoryBot.define do
  factory :institution_program do
    facility_code { generate :facility_code }
    program_type 'NCD'
    description 'COMPUTER SCIENCE'
    full_time_undergraduate '360'
    graduate '234'
    full_time_modifier 'S'
    length_in_hours '1001'
  end
end
