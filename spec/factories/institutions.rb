# frozen_string_literal: true

FactoryBot.define do
  factory :institution do
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
    bad_address { false }
    high_school { false }
    ownership_name { nil }

    trait :high_school_institution do
      high_school { true }
      institution { 'Walt Whitman High School' }
    end

    trait :in_nyc do
      city { 'NEW YORK' }
      state { 'NY' }
      country { 'USA' }
      physical_state { 'NY' }
      physical_country { 'USA' }
      ownership_name { 'test' }
    end

    trait :in_nyc_state_country do
      institution { 'Hampton' }
      city { 'NEW YORK' }
      state { 'NY' }
      country { 'USA' }
      physical_state { 'NY' }
      physical_country { 'USA' }
      ownership_name { 'test' }
    end

    trait :in_nyc_state_only do
      institution { 'Hampton' }
      city { 'NEW YORK' }
      state { 'NY' }
      physical_state { 'NY' }
      ownership_name { 'test' }
    end

    trait :in_new_rochelle do
      city { 'NEW ROCHELLE' }
      state { 'NY' }
      country { 'USA' }
      physical_state { 'NY' }
      physical_country { 'USA' }
      ownership_name { 'test' }
    end

    trait :in_chicago do
      physical_city { 'CHICAGO' }
      state { 'IL' }
      country { 'USA' }
      stem_offered { true }
      ownership_name { 'test' }
    end

    trait :uchicago do
      institution { 'UNIVERSITY OF CHICAGO - NOT IN CHICAGO' }
      institution_search { 'CHICAGO - NOT IN CHICAGO' }
      city { 'SOME OTHER CITY' }
      state { 'IL' }
      country { 'USA' }
      physical_state { 'IL' }
      physical_country { 'USA' }
      ownership_name { 'test' }
    end

    trait :independent_study do
      institution { 'UNIVERSITY OF INDEPENDENT STUDY' }
      institution_search { 'INDEPENDENT STUDY' }
      city { 'ALBUQUERQUE' }
      state { 'NM' }
      country { 'USA' }
      physical_state { 'NM' }
      physical_country { 'USA' }
      independent_study { true }
      ownership_name { 'test' }
    end

    trait :priority_enrollment do
      institution { 'UNIVERSITY OF PRIORITY ENROLLMENT' }
      institution_search { 'PRIORITY ENROLLMENT' }
      city { 'ALBUQUERQUE' }
      state { 'NM' }
      country { 'USA' }
      physical_state { 'NM' }
      physical_country { 'USA' }
      priority_enrollment { true }
      ownership_name { 'test' }
    end

    trait :start_like_harv do
      sequence(:institution) { |n| ["HARV#{n}", "HARV #{n}"].sample }
      city { 'BOSTON' }
      state { 'MA' }
      country { 'USA' }
      physical_state { 'MA' }
      physical_country { 'USA' }
      ownership_name { 'test' }

      after(:create) do |institution|
        create(:institution_program, :start_like_harv, institution_id: institution.id)
      end
    end

    trait :contains_harv do
      sequence(:institution) { |n| ["HASHARV#{n}", "HAS HARV #{n}"].sample }
      city { 'BOSTON' }
      state { 'MA' }
      country { 'USA' }
      physical_state { 'MA' }
      physical_country { 'USA' }
      ownership_name { 'test' }

      after(:create) do |institution|
        create(:institution_program, :contains_harv, institution_id: institution.id)
      end
    end

    trait :ca_employer do
      institution { 'ACME INC' }
      institution_search { 'ACME INC' }
      city { 'LOS ANGELES' }
      state { 'CA' }
      country { 'USA' }
      physical_state { 'CA' }
      physical_country { 'USA' }
      institution_type_name { 'OJT' }
      employer_provider { true }
      vet_tec_provider { false }
      school_provider { false }
      ownership_name { 'test' }
    end

    trait :institution_builder do
      facility_code { '1ZZZZZZZ' }
      ope { '00279100' }
      ope6 { '02791' }
      cross { '999999' }
      ownership_name { 'test' }
    end

    trait :section1015a do
      facility_code { '1ZZZZZZZ' }
    end

    trait :section1015b do
      facility_code { '2ZZZZZZZ' }
    end

    trait :vet_tec_provider do
      institution { 'COLLEGE OF VET TEC PROVIDER' }
      institution_search { 'VET TEC PROVIDER' }
      city { 'CHARLESTON' }
      state { 'SC' }
      country { 'USA' }
      physical_state { 'SC' }
      physical_country { 'USA' }
      vet_tec_provider { true }
      school_provider { false }
      employer_provider { false }
      ownership_name { 'test' }
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
      physical_state { 'SC' }
      physical_country { 'USA' }
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
      state { 'IL' }
      physical_country { 'USA' }
      country { 'USA' }
      physical_zip { '12345' }
    end

    trait :regular_address do
      physical_address_1 { '1400 Washington Ave' }
      physical_address_2 { '1400 Washington Ave #123' }
      physical_address_3 { 'Unit abc' }
      physical_city { 'ALBANY' }
      physical_state { 'NY' }
      physical_country { 'USA' }
      physical_zip { '12222' }
    end

    trait :regular_address_country do
      institution { 'University of Salerno' }
      physical_address_1 { 'Via Giovanni Paolo I' }
      physical_address_2 { 'Via Giovanni Paolo I#123' }
      physical_address_3 { 'Unit abc' }
      physical_city { 'SAlERNO' }
      physical_country { 'IT' }
    end

    trait :regular_address_country_nil do
      physical_address_1 { '1400 Washington Ave' }
      physical_address_2 { '1400 Washington Ave #123' }
      physical_address_3 { 'Unit abc' }
      physical_city { 'ALBANY' }
      physical_state { 'NY' }
      country { nil }
      physical_country { nil }
      physical_zip { '12222' }
    end

    trait :regular_address_2 do
      physical_address_1 { '1400 Washington bdvd 122123d' }
      physical_address_2 { '1400 Washington Ave' }
      physical_address_3 { 'Unit abc' }
      physical_city { 'ALBANY' }
      physical_state { 'NY' }
      physical_country { 'USA' }
      physical_zip { '12222' }
    end

    trait :bad_address do
      institution { '' }
      physical_address_1 { '1400 Washington Ave #123' }
      physical_address_2 { '1400 Washington Ave xwexewxwexwx' }
      physical_address_3 { 'Unit abc xwexwxwex' }
      physical_city { 'ALBANY' }
      physical_state { 'NY' }
      physical_country { 'USA' }
      physical_zip { '12222' }
    end

    trait :bad_address_with_name do
      institution { 'University at Albany' }
      physical_address_1 { '1400 Washington bdvd 122123d' }
      physical_address_2 { '1400 Washington Ave xwexewxwexwx' }
      physical_address_3 { 'Unit abc xwexwxwex' }
      physical_city { 'ALBANY' }
      physical_state { 'NY' }
      physical_country { 'USA' }
      physical_zip { '12222' }
    end

    trait :bad_address_with_name_numbered do
      institution { 'ATLANTA FIRE DEPARTMENT STATION #23' }
      physical_address_1 { '1400 Washington bdvd 122123d' }
      physical_address_2 { '1400 Washington Ave xwexewxwexwx' }
      physical_address_3 { 'Unit abc xwexwxwex' }
      physical_city { 'ATLANTA' }
      physical_state { 'GA' }
      physical_country { 'USA' }
    end

    trait :mailing_address do
      city { 'CHICAGO' }
      physical_city { 'CHICAGO' }
      physical_state { 'IL' }
      physical_country { 'USA' }
      state { 'IL' }
      country { 'USA' }
    end

    trait :production_version do
      version_id { Version.current_production.id }
    end

    trait :preview_version do
      version_id { Version.current_preview.id }
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
      address_1 { '81' }
      address_2 { 'Mary St' }
      city { 'Charleston' }
      physical_city { 'Charleston' }
      physical_state { 'SC' }
      physical_country { 'USA' }
      state { 'SC' }
      country { 'USA' }
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

    trait :mixed_addresses do
      physical_address_3 { nil }
      physical_address_2 { '7100 Whittier Blvd' }
      physical_address_1 { '8500 River Rd' }
      physical_city { 'Bethesda' }
      physical_state { 'MD' }
      physical_country { 'USA' }
      physical_zip { '20817' }
    end

    trait :foreign_bad_address do
      physical_address_1 { 'CASH OFFICE FIN SVCS' }
      physical_address_2 { 'UNIT 1 MARKET SQUARE' }
      physical_address_3 { nil }
      physical_city { 'HESLINGTON YORK' }
      physical_state { nil }
      physical_country { 'UNITED KINGDOM' }
      physical_zip { nil }
    end

    trait :ungeocodable do
      longitude { nil }
      latitude { nil }
      ungeocodable { true }
    end

    # accreditation_type is nil
    trait :accreditation_issue do
      institution { 'ACME INC' }
      ope { '00279100' }
      ope6 { '02791' }
    end

    trait :with_accreditation do
      institution { 'University of Toledo' }
      ope { '00279100' }
      ope6 { '02791' }
      accreditation_type { 'regional' }
    end
  end
end
