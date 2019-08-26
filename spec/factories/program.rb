# frozen_string_literal: true

FactoryBot.define do
  factory :program do
    facility_code { generate :facility_code }
    institution_name { 'NORTHEASTERN ILLINOIS UNIVERSITY' }
    program_type 'NCD'
    description 'COMPUTER SCIENCE'
    full_time_undergraduate '360'
    graduate '234'
    full_time_modifier 'S'
    length '1001'
  end
end
