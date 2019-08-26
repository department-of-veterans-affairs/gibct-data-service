# frozen_string_literal: true

FactoryBot.define do
  factory :sva do
    sequence :student_veteran_link do |n|
      "http://someplace_nice#{n}.com"
    end

    cross { generate :cross }

    trait :institution_builder do
      cross '999999'
    end

    initialize_with do
      new(cross: cross, student_veteran_link: student_veteran_link)
    end
  end
end
