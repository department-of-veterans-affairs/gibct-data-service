# frozen_string_literal: true

FactoryBot.define do
  factory :crosswalk_issue do
    trait :partial_match_type do
      issue_type { CrosswalkIssue::PARTIAL_MATCH_TYPE }
    end

    trait :ipeds_orphan_type do
      issue_type { CrosswalkIssue::IPEDS_ORPHAN_TYPE }
    end

    trait :with_weam_match do
      weam { create(:weam, :arf_gi_bill, cross: 'a', ope: 'b', city: 'Test', state: 'TN') }
    end

    trait :with_weam_match_partial do
      weam do
        create(:weam, :arf_gi_bill, cross: 'a', ope: 'b', institution: 'college of nowhere',
                                    city: 'Test', state: 'TN', zip: '99999')
      end
    end

    trait :with_weam_match_partial_physical_ca do
      weam do
        create(:weam, :arf_gi_bill, cross: 'a', ope: 'b', institution: 'college of nowhere',
                                    physical_city: 'Test', physical_state: 'CA',
                                    physical_address_1: '123 test st', physical_zip: '99999', state: nil)
      end
    end

    trait :with_ipeds_hd_match do
      ipeds_hd { create(:ipeds_hd, cross: 'a', ope: 'b') }
    end

    trait :with_crosswalk_match do
      crosswalk { create(:crosswalk, cross: 'a', ope: 'b') }
    end
  end
end
