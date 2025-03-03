# frozen_string_literal: true

FactoryBot.define do
  factory :lcpe_lac, class: 'Lcpe::Lac' do
    facility_code
    edu_lac_type_nm { 'License' }
    lac_nm { 'Gas Fitter' }
    state { 'AR' }

    trait :preloaded do
      after(:create) { |instance| Lcpe::PreloadDataset.build(instance.class.to_s) }
    end
  end
end
