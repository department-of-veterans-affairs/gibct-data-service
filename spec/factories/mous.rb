# frozen_string_literal: true
FactoryGirl.define do
  factory :mou do
    ope { generate :ope }

    trait :by_dod do
      status 'probation - dod'
    end

    trait :by_title_iv do
      status 'title iv non-compliant'
    end
  end
end
