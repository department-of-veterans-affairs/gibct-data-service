# frozen_string_literal: true
FactoryGirl.define do
  factory :vsoc do
    institution { 'SOME SCHOOL' }
    facility_code { generate :facility_code }

    vetsuccess_name { 'Fred Flintstone' }
    vetsuccess_email { 'someone@someplace.com' }

    trait :institution_builder do
      facility_code '1ZZZZZZZ'
    end
  end
end
