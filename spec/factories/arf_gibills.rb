FactoryGirl.define do
  factory :arf_gibill do
    sequence(:facility_code) { |n| n.to_s(32).rjust(8, '0') }
    institution { Faker::University.name }
    gibill { Faker::Number.number(5) }
  end
end
