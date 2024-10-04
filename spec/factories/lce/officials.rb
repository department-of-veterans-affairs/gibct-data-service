# frozen_string_literal: true

FactoryBot.define do
  factory :lce_official, class: 'Lce::Official' do
    name { 'MyString' }
    title { 'MyString' }
    institution { nil }
  end
end
