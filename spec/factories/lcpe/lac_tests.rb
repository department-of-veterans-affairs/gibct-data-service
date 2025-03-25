# frozen_string_literal: true

FactoryBot.define do
  factory :lcpe_lac_test, class: 'Lcpe::LacTest' do
    test_nm { 'Restricted Gas Fitter Examination' }
    fee_amt { 75 }
  end
end
