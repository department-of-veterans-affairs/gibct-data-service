# frozen_string_literal: true

FactoryBot.define do
  factory :lcpe_exam, class: 'Lcpe::Exam' do
    facility_code { '57001151' }
    nexam_nm { 'AP-ADVANCED PLACEMENT EXAMS' }
  end
end
