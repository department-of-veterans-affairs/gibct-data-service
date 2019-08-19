# frozen_string_literal: true

FactoryGirl.define do
  factory :weams_certifying_official do
    facility_code { generate :facility_code }
    institution_name { 'Clements Ferry University' }
    priority { 'PRIMARY' }
    first_name { 'Donald' }
    last_name { 'Sample' }
    title { 'Certifying Official for Programs' }
    phone_area_code { '843' }
    phone_number { '1337852' }
    phone_extension { '1234' }
    email { 'dsample@cfu.edu' }
  end
end
