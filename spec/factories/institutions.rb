# frozen_string_literal: true

FactoryBot.define do
  factory :institution do
    sequence(:id) { |n| n }
    facility_code { generate :facility_code }
    cross { generate :cross }
    sequence(:institution, 1000) { |n| "institution #{n}" }
    institution_search { institution }
    sequence(:country) { |n| "country #{n}" }
    sequence(:insturl) { |n| "www.school.edu/#{n}" }
    institution_type_name { 'PRIVATE' }
    school_provider { true }
    employer_provider { false }
    vet_tec_provider { false }
    school_closing { false }

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
      physical_city { 'CHICAGO' }
      physical_state { 'IL' }
      physical_country { 'USA' }
      stem_offered { true }
    end

    trait :uchicago do
      institution { 'UNIVERSITY OF CHICAGO - NOT IN CHICAGO' }
      institution_search { 'CHICAGO - NOT IN CHICAGO' }
      city { 'SOME OTHER CITY' }
      state { 'IL' }
      country { 'USA' }
    end

    trait :independent_study do
      institution { 'UNIVERSITY OF INDEPENDENT STUDY' }
      institution_search { 'INDEPENDENT STUDY' }
      city { 'ALBUQUERQUE' }
      state { 'NM' }
      country { 'USA' }
      independent_study { true }
    end

    trait :priority_enrollment do
      institution { 'UNIVERSITY OF PRIORITY ENROLLMENT' }
      institution_search { 'PRIORITY ENROLLMENT' }
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
      institution_search { 'ACME INC' }
      city { 'LOS ANGELES' }
      state { 'CA' }
      country { 'USA' }
      institution_type_name { 'OJT' }
      employer_provider { true }
      vet_tec_provider { false }
      school_provider { false }
    end

    trait :institution_builder do
      facility_code { '1ZZZZZZZ' }
      ope { '00279100' }
      ope6 { '02791' }
      cross { '999999' }
    end

    trait :vet_tec_provider do
      institution { 'COLLEGE OF VET TEC PROVIDER' }
      institution_search { 'VET TEC PROVIDER' }
      city { 'CHARLESTON' }
      state { 'SC' }
      country { 'USA' }
      vet_tec_provider { true }
      school_provider { false }
      employer_provider { false }
    end

    trait :exclude_caution_flags do
      count_of_caution_flags { 1 }
      caution_flag { true }
    end

    trait :exclude_school_closing do
      count_of_caution_flags { 1 }
      caution_flag { true }
    end

    trait :preferred_provider do
      city { 'CHARLESTON' }
      state { 'SC' }
      country { 'USA' }
      preferred_provider { true }
      vet_tec_provider { true }
    end

    trait :closure109 do
      facility_code { '1ZZZZZZZ' }
      institution { 'COLLEGE OF VET TEC PROVIDER' }
      institution_search { 'VET TEC PROVIDER' }
      closure109 { false }
    end

    trait :physical_address do
      physical_address_1 { '123' }
      physical_address_2 { 'Main St' }
      physical_address_3 { 'Unit abc' }
      physical_city { 'CHICAGO' }
      physical_state { 'IL' }
      physical_country { 'USA' }
      physical_zip { '12345' }
    end

    trait :mailing_address do
      address_1 { '123' }
      address_2 { 'Main St' }
      address_3 { 'Unit abc' }
      city { 'CHICAGO' }
      state { 'IL' }
      country { 'USA' }
    end

    trait :production_version do
      version_id { Version.current_production.id }
    end

    trait :mit do
      ialias { 'MIT' }
      institution { 'MUST INVESTIGATE TARANTULAS' }
      institution_search { 'MUST INVESTIGATE TARANTULAS' }
      city { 'ARACHNID' }
      gibill { 100 }
    end

    trait :ku do
      ialias { 'KU | KANSAS UNIVERSITY' }
      institution { 'KANSAS UNIVERSITY NORTH' }
      institution_search { 'KANSAS NORTH' }
    end

    trait :location do
      latitude { 32.790803 }
      longitude { -79.938087 }
      institution { 'CHARLESTON SCHOOL OF LAW' }
    end

    trait :employer do
      vet_tec_provider { false }
      school_provider { false }
      employer_provider { true }
      institution_type_name { Institution::EMPLOYER }
    end

    trait :lat_long do
      latitude { 0 }
      longitude { 0 }
    end
  end
end
