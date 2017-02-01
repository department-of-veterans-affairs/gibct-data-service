FactoryGirl.define do
  factory :outcome do
    sequence(:facility_code) { |n| n.to_s(32).rjust(8, '0') }
    institution { Faker::University.name }

    retention_rate_veteran_ba { Faker::Number.decimal(0) }
    retention_rate_veteran_otb { Faker::Number.decimal(0) }
    persistance_rate_veteran_ba { Faker::Number.decimal(0) }
    persistance_rate_veteran_otb { Faker::Number.decimal(0) }
    graduation_rate_veteran { Faker::Number.decimal(0) }
    transfer_out_rate_veteran { Faker::Number.decimal(0) }
  end
end
