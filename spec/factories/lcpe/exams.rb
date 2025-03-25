# frozen_string_literal: true

FactoryBot.define do
  factory :lcpe_exam, class: 'Lcpe::Exam' do
    nexam_nm { 'AP-ADVANCED PLACEMENT EXAMS' }

    trait :preloaded do
      after(:create) { |instance| Lcpe::PreloadDataset.build(instance.class.to_s) }
    end
  end
end
