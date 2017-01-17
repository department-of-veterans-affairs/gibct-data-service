# frozen_string_literal: true
FactoryGirl.define do
  factory :p911_yr do
    institution { 'SOME SCHOOL' }
    facility_code { generate :facility_code }
    p911_yellow_ribbon { 1 }
    p911_yr_recipients { 1 }
  end
end
