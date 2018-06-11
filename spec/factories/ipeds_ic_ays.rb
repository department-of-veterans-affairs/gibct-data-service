# frozen_string_literal: true

FactoryGirl.define do
  factory :ipeds_ic_ay do
    cross { generate :cross }

    tuition_in_state 1.0
    tuition_out_of_state 1.0
    books 1.0

    trait :institution_builder do
      cross '999999'
    end

    initialize_with do
      new(cross: cross, tuition_in_state: tuition_in_state, tuition_out_of_state: tuition_out_of_state, books: books)
    end
  end
end
