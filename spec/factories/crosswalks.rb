# frozen_string_literal: true
FactoryGirl.define do
  factory :crosswalk do
    institution { 'Some School' }
    facility_code { generate :facility_code }
    ope { generate :ope }
    cross { generate :cross }
  end
end
