FactoryGirl.define do
  factory :data_csv do
    sequence(:facility_code) { |n| n.to_s(32).rjust(8, '0') }
    institution { Faker::University.name }
  end
end
