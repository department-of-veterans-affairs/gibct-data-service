# frozen_string_literal: true

FactoryBot.define do
  factory :in_state_tuition_policy_url do
    facility_code { generate :facility_code }
    in_state_tuition_information { 'Contact the School Certifying Official (SCO) for requirements' }
  end
end
