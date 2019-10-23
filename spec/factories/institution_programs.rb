# frozen_string_literal: true

FactoryBot.define do
  factory :institution_program do
    facility_code { generate :facility_code }
    program_type { 'NCD' }
    description { 'COMPUTER SCIENCE' }
    full_time_undergraduate { '360' }
    graduate { '234' }
    full_time_modifier { 'S' }
    length_in_hours { '1001' }
    school_locale { 'City' }
    provider_website { 'www.test.com' }
    provider_email_address { 'test@test.com' }
    phone_area_code { '555' }
    phone_number { '123-4567' }
    student_vet_group { 'Yes' }
    student_vet_group_website { 'www.test.com' }
    vet_success_name { 'success name' }
    vet_success_email { 'test@test.com' }
    vet_tec_program { 'COMPUTER SCIENCE' }
    tuition_amount { '360' }
    length_in_weeks { '1001' }
  end
end
