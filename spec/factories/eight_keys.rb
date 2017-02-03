# frozen_string_literal: true
FactoryGirl.define do
  factory :eight_key do
    institution { 'SOME SCHOOL' }
    city { 'Cupcakes' }
    state { 'NY' }
    ope { generate :ope }
    cross { generate :cross }

    trait :institution_builder do
      ope '99999999'
      cross '999999'
    end
  end
end
