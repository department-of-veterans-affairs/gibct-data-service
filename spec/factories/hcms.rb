# frozen_string_literal: true
FactoryGirl.define do
  factory :hcm do
    ope { generate :ope }
    hcm_type 'hcm - cash monitoring 1'
    hcm_reason 'audit late/missing'

    trait :institution_builder do
      ope '99999999'
    end

    initialize_with do
      new(ope: ope, hcm_type: hcm_type, hcm_reason: hcm_reason)
    end
  end
end
