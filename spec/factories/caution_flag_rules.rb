# frozen_string_literal: true

FactoryBot.define do
  factory :caution_flag_rule do
    trait :accreditation_rule do
      rule { create(:rule, :accreditation_source) }
      title { 'School has an accreditation issue' }
      description { "This school's accreditation has been revoked and is under appeal." }
      link_text { "Learn more about this school's accreditation" }
      link_url { 'http://ope.ed.gov/accreditation' }
    end

    trait :settlement_rule do
      rule { create(:rule, :settlement_reason) }
      title { 'School has an accreditation issue' }
      description { "This school's accreditation has been revoked and is under appeal." }
      link_text { "Learn more about this school's accreditation" }
      link_url { 'http://ope.ed.gov/accreditation' }
    end

    trait :closing_settlement_rule do
      rule { create(:rule, :closing_settlement_reason) }
      title { 'Campus will be closing soon' }
      description { 'This campus will be closing soon.' }
      link_text { "Visit the school's website to learn more" }
      link_url { 'SCHOOL_URL' }
    end
  end
end
