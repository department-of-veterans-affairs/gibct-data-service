# frozen_string_literal: true

FactoryBot.define do
  factory :accreditation_type_keyword do
    accreditation_type { 'regional' }
    keyword_match { 'middle' }

    trait :accreditation_type_regional do
      keyword_match { 'northwest' }
    end

    trait :accreditation_type_national do
      accreditation_type { 'national' }
      keyword_match { 'career schools' }
    end

    trait :accreditation_type_hybrid do
      accreditation_type { 'hybrid' }
      keyword_match { 'midwifery' }
    end

    # appears in two different accreditation types
    trait :hybrid_career_schools do
      accreditation_type { 'hybrid' }
      keyword_match { 'career schools' }
    end

    trait :regional_career_schools do
      accreditation_type { 'regional' }
      keyword_match { 'career schools' }
    end
  end
end
