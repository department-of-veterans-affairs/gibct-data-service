# frozen_string_literal: true

FactoryBot.define do
  factory :lcpe_exam, class: 'Lcpe::Exam' do
    facility_code { '57001151' }
    nexam_nm { 'AP-ADVANCED PLACEMENT EXAMS' }

    trait :preloaded do
      after(:create) { |instance| Lcpe::PreloadDataset.build(instance.class.to_s) }
    end
  end
end
