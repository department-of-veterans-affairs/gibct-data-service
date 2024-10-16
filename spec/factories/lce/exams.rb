# frozen_string_literal: true

FactoryBot.define do
  factory :lce_exam, class: 'Lce::Exam' do
    name { 'MyString' }
    description { 'MyText' }
    dates { '2024-10-04' }
    amount { '9.99' }
    institution { nil }
  end
end
