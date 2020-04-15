# frozen_string_literal: true

FactoryBot.define do
  factory :rule do
    rule_name { CautionFlag.name }
    matcher { Rule::MATCHERS[:has] }
    subject { nil }

    object { 'test' }
    predicate { 'is' }

    trait :accreditation_source do
      object { AccreditationAction.name }
      predicate { 'source' }
    end

    trait :settlement_reason do
      object { 'Settlement with U.S. Government' }
      predicate { 'reason' }
    end

    trait :closing_settlement_reason do
      object { 'closing reason' }
      predicate { 'reason' }
    end
  end
end
