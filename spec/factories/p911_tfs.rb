FactoryGirl.define do
  factory :p911_tf do
    sequence(:facility_code) { |n| n.to_s(32).rjust(8, '0') }
    institution { Faker::University.name }

    p911_recipients { Faker::Number.between(1, 22_000) }
    p911_tuition_fees { Faker::Number.decimal(9) }
  end
end
