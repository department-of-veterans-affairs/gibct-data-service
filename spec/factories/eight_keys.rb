# frozen_string_literal: true
FactoryGirl.define do
  factory :eight_key do
    institution { 'SOME SCHOOL' }
    city { 'Cupcakes' }
    state { 'NY' }
    ope { generate :ope }
    cross { generate :cross }
  end
end
