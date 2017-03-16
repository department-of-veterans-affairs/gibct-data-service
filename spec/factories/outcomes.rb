# frozen_string_literal: true
FactoryGirl.define do
  factory :outcome do
    facility_code { generate :facility_code }

    retention_rate_veteran_ba 0.1
    retention_rate_veteran_otb 0.2
    persistance_rate_veteran_ba 0.3
    persistance_rate_veteran_otb 0.4
    graduation_rate_veteran 0.5
    transfer_out_rate_veteran 0.6

    trait :institution_builder do
      facility_code '1ZZZZZZZ'
    end

    initialize_with do
      new(
        facility_code: facility_code, retention_rate_veteran_ba: retention_rate_veteran_ba,
        retention_rate_veteran_otb: retention_rate_veteran_otb,
        persistance_rate_veteran_ba: persistance_rate_veteran_ba,
        persistance_rate_veteran_otb: persistance_rate_veteran_otb,
        graduation_rate_veteran: graduation_rate_veteran,
        transfer_out_rate_veteran: transfer_out_rate_veteran
      )
    end
  end
end
