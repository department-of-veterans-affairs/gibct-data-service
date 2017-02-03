# frozen_string_literal: true
FactoryGirl.define do
  factory :ipeds_ic_py do
    cross { generate :cross }

    chg1py3 1
    books 1

    trait :institution_builder do
      cross '999999'
    end
  end
end
