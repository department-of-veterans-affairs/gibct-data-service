# frozen_string_literal: true

FactoryGirl.define do
  factory :eight_key do
    ope { generate :ope }
    cross { generate :cross }

    trait :institution_builder do
      ope '00279100'
      cross '999999'
    end

    initialize_with do
      new(ope: ope, cross: cross)
    end
  end
end
