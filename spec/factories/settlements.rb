FactoryGirl.define do
  factory :settlement do
    institution { Faker::University.name }
    sequence(:cross) { |n| DS::IpedsId.pad(n.to_s) }

    settlement_description { 'Settlement with U.S. Government' }
  end
end
