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

    trait :with_institution_and_institution_children do
      after(:create) do |version|
        create(:zipcode_rate, version_id: version.id)
        create(:institution, :with_dependent_children, version_id: version.id, version: version)
      end
    end

    trait :prod_vsn_w_inst_accr_iss_caution_flag do
      after(:create) do |version|
        create(:institution, :caution_flag_accreditation_issue, version_id: version.id, version: version)
      end
    end
  end
end
