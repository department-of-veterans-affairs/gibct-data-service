# frozen_string_literal: true

FactoryBot.define do
  factory :caution_flag do
    trait :accreditation_issue do
      source { 'accreditation' }
      title { 'School has an accreditation issue' }
      description { "This school's accreditation has been revoked and is under appeal, or the school has been placed on probation as it didn't meet acceptable levels of quality." }
      link_text { "Learn more about this school's accreditation" }
      link_url { "http://ope.ed.gov/accreditation" }
    end
  end
end
