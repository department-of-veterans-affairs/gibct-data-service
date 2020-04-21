# frozen_string_literal: true

FactoryBot.define do
  factory :ignored_crosswalk_issue do
    trait :matchable_by_facility_code do
      facility_code { '99Z99999' }
    end

    trait :matchable_by_cross do
      cross { '888888' }
    end

    trait :matchable_by_ope do
      ope { '88888888' }
    end
  end
end
