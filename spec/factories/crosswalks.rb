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
