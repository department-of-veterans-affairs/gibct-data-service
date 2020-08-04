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
  end
end
