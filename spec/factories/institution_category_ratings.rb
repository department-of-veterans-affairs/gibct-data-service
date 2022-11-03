# frozen_string_literal: true

FactoryBot.define do
  factory :institution_category_rating do
    association :institution, factory: :institution
    category_name { 'overall_experience' }
  end
end
