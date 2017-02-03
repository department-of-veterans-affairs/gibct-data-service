# frozen_string_literal: true
FactoryGirl.define do
  factory :sva do
    sequence :institution do |n|
      "institution #{n}"
    end

    sequence :student_veteran_link do |n|
      "http://someplace_nice#{n}.com"
    end

    cross { generate :cross }

    trait :institution_builder do
      cross '999999'
    end
  end
end
