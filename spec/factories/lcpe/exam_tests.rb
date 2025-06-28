# frozen_string_literal: true

FactoryBot.define do
  factory :lcpe_exam_test, class: 'Lcpe::ExamTest' do
    association :lcpe_exam, factory: :lcpe_exam

    descp_txt { 'AP Exam Fee International' }
    fee_amt { 127 }
    begin_dt { '01-NOV-16' }
    end_dt { '30-NOV-23' }
  end
end
