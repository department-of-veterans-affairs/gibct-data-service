# frozen_string_literal: true

FactoryBot.define do
  factory :rule do
    trait :accreditation_source do
      rule_name { CautionFlag.name }
      matcher { Rule::MATCHERS[:has] }
      subject { nil }

      object { AccreditationAction.name }
      predicate { 'source' }
    end

    trait :settlement_reason
    rule_name { CautionFlag.name }
    matcher { Rule::MATCHERS[:has] }
    subject { nil }

    object { 'Settlement with U.S. Government' }
    predicate { 'reason' }
  end
end
