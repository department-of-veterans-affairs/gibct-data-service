# frozen_string_literal: true

FactoryBot.define do
  factory :institution do
    sequence(:id) { |n| n }
    facility_code { generate :facility_code }
    cross { generate :cross }
    sequence(:institution, 1000) { |n| "institution #{n}" }
    sequence(:country) { |n| "country #{n}" }
    sequence(:insturl) { |n| "www.school.edu/#{n}" }
    institution_type_name { 'PRIVATE' }
    version { 1 }
    approved { true }

    trait :in_nyc do
      city { 'NEW YORK' }
      state { 'NY' }
      country { 'USA' }
    end

    trait :in_new_rochelle do
      city { 'NEW ROCHELLE' }
      state { 'NY' }
      country { 'USA' }
    end

    trait :in_chicago do
      city { 'CHICAGO' }
      state { 'IL' }
      country { 'USA' }
      stem_offered { true }
    end

    trait :uchicago do
      institution { 'UNIVERSITY OF CHICAGO - NOT IN CHICAGO' }
      city { 'SOME OTHER CITY' }
      state { 'IL' }
      country { 'USA' }
    end

    trait :independent_study do
      institution { 'UNIVERSITY OF INDEPENDENT STUDY' }
      city { 'ALBUQUERQUE' }
      state { 'NM' }
      country { 'USA' }
      independent_study { true }
    end

    trait :priority_enrollment do
      institution { 'UNIVERSITY OF PRIORITY ENROLLMENT' }
      city { 'ALBUQUERQUE' }
      state { 'NM' }
      country { 'USA' }
      priority_enrollment { true }
    end

    trait :start_like_harv do
      sequence(:institution) { |n| ["HARV#{n}", "HARV #{n}"].sample }
      city { 'BOSTON' }
      state { 'MA' }
      country { 'USA' }
    end

    trait :contains_harv do
      sequence(:institution) { |n| ["HASHARV#{n}", "HAS HARV #{n}"].sample }
      city { 'BOSTON' }
      state { 'MA' }
      country { 'USA' }
    end

    trait :ca_employer do
      institution { 'ACME INC' }
      city { 'LOS ANGELES' }
      state { 'CA' }
      country { 'USA' }
      institution_type_name { 'OJT' }
    end

    trait :institution_builder do
      facility_code { '1ZZZZZZZ' }
      ope { '00279100' }
      ope6 { '02791' }
      cross { '999999' }
      version { 1 }
    end

    trait :vet_tec_provider do
      institution { 'COLLEGE OF VET TEC PROVIDER' }
      city { 'CHARLESTON' }
      state { 'SC' }
      country { 'USA' }
      vet_tec_provider { true }
    end

    trait :vet_tec_preferred_provider do
      institution { 'COLLEGE OF VET TEC PROVIDER' }
      city { 'CHARLESTON' }
      state { 'SC' }
      country { 'USA' }
      vet_tec_provider { true }
      preferred_provider { true }
    end

    trait :closure109 do
      facility_code { '1ZZZZZZZ' }
      institution { 'COLLEGE OF VET TEC PROVIDER' }
      closure109 { false }
    end

    trait :physical_address do
      physical_city { 'CHICAGO' }
      physical_state { 'IL' }
      physical_country { 'USA' }
    end
  end
end
