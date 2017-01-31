# frozen_string_literal: true
FactoryGirl.define do
  factory :ipeds_ic_ay do
    cross { generate :cross }

    tuition_in_state 1
    tuition_out_of_state 1
    books 1
  end
end
