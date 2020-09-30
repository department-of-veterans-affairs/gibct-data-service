# frozen_string_literal: true

FactoryBot.define do
  factory :institution_category_rating do
    category_name { 'overall_experience' }
    institution_id { 1234 }

  end
end
