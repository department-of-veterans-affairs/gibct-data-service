# frozen_string_literal: true

FactoryGirl.define do
  factory :stem_cip_code do
    two_digit_series 1
    twentyten_cip_code 1.0901
    cip_code_title 'Animal Sciences, General'
  end
end
