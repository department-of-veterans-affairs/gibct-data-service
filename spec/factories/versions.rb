# frozen_string_literal: true

FactoryBot.define do
  factory :version do
    transient do
      year { Time.zone.now.year }
      date { Time.current.change(year: year) }
    end

    user

    trait :production do
      production { true }
      geocoded { true }
    end

    # Set :year transient value in conjunction with :from_year trait
    # Used to test #latest_from_year and #latest_from_year_range
    trait :from_year do
      completed_at { date }
    end

    trait :preview do
      production { false }
    end

    trait :with_institution do
      after(:create) do |version|
        create(:institution, version_id: version.id, version: version)
      end
    end

    trait :with_institution_regular_address do
      after(:create) do |version|
        create(:institution, :regular_address, version_id: version.id, version: version)
      end
    end

    trait :with_institution_accreditation_issue do
      after(:create) do |version|
        create(:institution, :accreditation_issue, version_id: version.id, version: version)
      end
    end

    trait :with_accredited_institution do
      after(:create) do |version|
        create(:institution, :with_accreditation, version_id: version.id, version: version)
      end
    end

    trait :with_ungecodable_foreign_institution do
      after(:create) do |version|
        create(:institution, :foreign_bad_address, :ungeocodable, version_id: version.id, version: version)
      end
    end

    trait :with_geocoded_institution do
      after(:create) do |version|
        create(:institution, :location, :lat_long, version_id: version.id, version: version)
      end
    end

    trait :with_institution_that_contains_harv do
      after(:create) do |version|
        create(:institution, :contains_harv, version_id: version.id, version: version)
      end
    end

    trait :with_institution_that_starts_like_harv do
      after(:create) do |version|
        create(:institution, :start_like_harv, version_id: version.id, version: version)
      end
    end
  end
end
