# frozen_string_literal: true
FactoryGirl.define do
  factory :vsoc do
    facility_code { generate :facility_code }

    vetsuccess_name { 'Fred Flintstone' }
    vetsuccess_email { 'someone@someplace.com' }

    trait :institution_builder do
      facility_code '1ZZZZZZZ'
    end

    initialize_with do
      new(
        facility_code: facility_code, vetsuccess_email: vetsuccess_email,
        vetsuccess_name: vetsuccess_name
      )
    end
  end
end
