# frozen_string_literal: true

FactoryBot.define do
  factory :institution_program do
    version 1
    facility_code { generate :facility_code }
    program_type 'NCD'
    institution_name 'TEST'
    description 'COMPUTER SCIENCE'
    full_time_undergraduate '360'
    graduate '234'
    full_time_modifier 'S'
    length_in_hours '1001'
    school_locale 'City'
    provider_website 'www.test.com'
    provider_email_address 'test@test.com'
    phone_area_code '555'
    phone_number '123-4567'
    student_vet_group 'Yes'
    student_vet_group_website 'www.test.com'
    vet_success_name 'success name'
    vet_success_email 'test@test.com'
    vet_tec_program 'COMPUTER SCIENCE'
    tuition_amount '360'
    length_in_weeks '1001'
    dod_bah '1000'
    va_bah '1200'

    trait :start_like_harv do
      sequence(:institution_name) { |n| ["HARV#{n}", "HARV #{n}"].sample }
      institution_city 'BOSTON'
      institution_state 'MA'
      institution_country 'USA'
    end

    trait :contains_harv do
      sequence(:institution_name) { |n| ["HASHARV#{n}", "HAS HARV #{n}"].sample }
      institution_city 'BOSTON'
      institution_state 'MA'
      institution_country 'USA'
    end

    trait :in_nyc do
      institution_city 'NEW YORK'
      institution_state 'NY'
      institution_country 'USA'
    end

    trait :in_new_rochelle do
      institution_city 'NEW ROCHELLE'
      institution_state 'NY'
      institution_country 'USA'
    end

    trait :in_chicago do
      institution_city 'CHICAGO'
      institution_state 'IL'
      institution_country 'USA'
    end
  end
end
