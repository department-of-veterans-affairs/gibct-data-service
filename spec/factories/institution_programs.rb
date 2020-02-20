# frozen_string_literal: true

FactoryBot.define do
  factory :institution_program do
    version { 1 }
    sequence(:description) { |n| "PROGRAM #{n}" }
    program_type { 'NCD' }
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
    institution

    trait :start_like_harv do
      sequence(:description) { |n| ["HARV#{n}", "HARV #{n}"].sample }
    end

    trait :contains_harv do
      sequence(:description) { |n| ["HASHARV#{n}", "HAS HARV #{n}"].sample }
    end

    trait :in_nyc do
      institution { create(:institution, physical_city: 'NEW YORK', physical_country: 'USA', physical_state: 'NY', version_id: Version.last.id) }
    end

    trait :in_new_rochelle do
      institution { create(:institution, physical_city: 'NEW ROCHELLE', physical_country: 'USA', physical_state: 'NY', version_id: Version.last.id) }
    end

    trait :in_chicago do
      institution { create(:institution, physical_city: 'CHICAGO', physical_country: 'USA', physical_state: 'IL', version_id: Version.last.id) }
    end

    trait :preferred_provider do
      institution { create(:institution, preferred_provider: true, version_id: Version.last.id) }
    end

    trait :ca_employer do
      institution { create(:institution, :ca_employer, version_id: Version.last.id) }
    end
  end
end
