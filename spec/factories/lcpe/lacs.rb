# frozen_string_literal: true

FactoryBot.define do
  factory :lcpe_lac, class: 'Lcpe::Lac' do
    facility_code
    edu_lac_type_nm { 'License' }
    lac_nm { 'Gas Fitter' }
    state { 'AR' }
  end
end
