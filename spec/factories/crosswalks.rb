# frozen_string_literal: true

FactoryBot.define do
  factory :crosswalk do
    sequence :institution do |n|
      "institution #{n}"
    end

    facility_code { generate :facility_code }
    ope { generate :ope }
    cross { generate :cross }

    trait :institution_builder do
      facility_code { '1ZZZZZZZ' }
      ope { '00279100' }
      cross { '999999' }
    end

    trait :crosswalk_issue_matchable_by_facility_code do
      facility_code { '99Z99999' }
    end

    # last 2 characters are less than 51
    trait :domestic_with_crosswalk_issue do
      facility_code { '99Z99950' }
      after(:create) do |crosswalk|
        create(:crosswalk_issue, :partial_match_type, crosswalk: crosswalk)
      end
    end

    # last 2 characters are 51 or greater
    trait :foreign_with_crosswalk_issue do
      facility_code { '99Z99951' }
      after(:create) do |crosswalk|
        create(:crosswalk_issue, :partial_match_type, crosswalk: crosswalk)
      end
    end

    trait :crosswalk_issue_matchable_by_cross do
      cross { '888888' }
    end

    trait :crosswalk_issue_matchable_by_ope do
      ope { '88888888' }
    end

    initialize_with do
      new(facility_code: facility_code, ope: ope, cross: cross)
    end
  end
end
