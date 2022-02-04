# frozen_string_literal: true

FactoryBot.define do
  factory :ipeds_hd do
    cross { generate :cross }
    vet_tuition_policy_url { 'http://example.com' }
    f1sysnam { 'example school' }
    f1syscod { 123 }
    ialias { 'exsc' }

    trait :institution_builder do
      cross { '999999' }
    end

    trait :crosswalk_issue_matchable_by_cross do
      cross { '888888' }
    end

    trait :crosswalk_issue_matchable_by_ope do
      ope { '88888888' }
    end

    initialize_with do
      new(
        cross: cross, vet_tuition_policy_url: vet_tuition_policy_url,
        f1sysnam: f1sysnam, f1syscod: f1syscod, ialias: ialias
      )
    end
  end
end
