# frozen_string_literal: true

FactoryBot.define do
  factory :preview_generation_status_information do
    current_progress { 'Preview Version is being generated.' }

    trait :publishing do
      current_progress { 'archiving institutions' }
    end

    trait :complete do
      current_progress { CommonInstitutionBuilder::VersionGeneration::PUBLISH_COMPLETE_TEXT }
    end

    trait :complete_error do
      current_progress { 'There was an error...' }
    end
  end
end
