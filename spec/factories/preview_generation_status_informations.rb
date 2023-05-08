# frozen_string_literal: true

FactoryBot.define do
  factory :preview_generation_status_information do
    current_progress { 'Preview Version is being generated.' }

    trait :complete do
      current_progress { 'Preview generated and published' }
    end

    trait :complete_error do
      current_progress { 'There was an error...' }
    end
  end
end
