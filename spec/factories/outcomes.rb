# frozen_string_literal: true
FactoryGirl.define do
  factory :outcome do
    facility_code { generate :facility_code }
  end
end
