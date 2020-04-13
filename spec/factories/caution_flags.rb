# frozen_string_literal: true

FactoryBot.define do
  factory :caution_flag do
    trait :accreditation_issue do
      source { AccreditationAction.name }
      title { 'School has an accreditation issue' }
      description { "This school's accreditation has been revoked and is under appeal." }
      link_text { "Learn more about this school's accreditation" }
      link_url { 'http://ope.ed.gov/accreditation' }
    end

    trait :accreditation_issue_pre_map do
      source { AccreditationAction.name }
    end

    trait :settlement_pre_map do
      source { Settlement.name }
      reason { 'Settlement with U.S. Government' }
    end
  end
end
