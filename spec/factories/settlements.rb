# frozen_string_literal: true
FactoryGirl.define do
  factory :settlement do
    institution { 'Some School' }
    cross { generate :cross }

    settlement_description { 'Settlement with U.S. Government' }
  end
end
