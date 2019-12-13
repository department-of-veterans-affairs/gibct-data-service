# frozen_string_literal: true

FactoryBot.define do
  factory :crosswalk_issue do

    trait :with_weam_match do
      weam { create(:weam, cross: 'a', ope: 'b', institution: 'c', facility_code: 'd') }
    end

    trait :with_ipeds_hd_match do
      ipeds_hd { create(:ipeds_hd, cross: 'a', ope: 'b') }
    end

    trait :with_crosswalk_match do
      crosswalk { create(:crosswalk, cross: 'a', ope: 'b') }
    end

  end
end
