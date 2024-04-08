# frozen_string_literal: true

FactoryBot.define do
  factory :version do
    user

    trait :production do
      production { true }
      geocoded { true }
    end

    trait :preview do
      production { false }
    end

    trait :with_institution do
      after(:create) do |version|
        create(:institution, version_id: version.id, version: version)
      end
    end
  end
end
