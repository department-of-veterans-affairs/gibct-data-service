# frozen_string_literal: true
FactoryGirl.define do
  factory :institution do
    sequence(:id) { |n| n }
    facility_code { generate :facility_code }
    cross { generate :cross }
    sequence(:institution) { |n| "institution #{n}" }
    sequence(:country) { |n| "country #{n}" }
    sequence(:insturl) { |n| "www.school.edu/#{n}" }
    institution_type_name 'private'
    version 1

    trait :in_nyc do
      city 'new york'
      state 'ny'
      country 'usa'
    end

    trait :in_new_rochelle do
      city 'new rochelle'
      state 'ny'
      country 'usa'
    end

    trait :in_chicago do
      city 'chicago'
      state 'il'
      country 'usa'
    end

    trait :uchicago do
      institution 'university of chicago - not in chicago'
      city 'some other city'
      state 'il'
      country 'usa'
    end

    trait :start_like_harv do
      sequence(:institution) { |n| ["harv#{n}", "harv #{n}"].sample }
      city 'boston'
      state 'ma'
      country 'usa'
    end

    trait :contains_harv do
      sequence(:institution) { |n| ["hasharv#{n}", "has harv #{n}"].sample }
      city 'boston'
      state 'ma'
      country 'usa'
    end

    trait :institution_builder do
      facility_code '1ZZZZZZZ'
      ope '99999999'
      ope6 '99999'
      cross '999999'
    end
  end
end
