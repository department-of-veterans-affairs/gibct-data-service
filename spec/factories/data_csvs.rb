FactoryGirl.define do
  factory :data_csv do
    sequence :facility_code do |n| n.to_s(32).rjust(8, "0") end
    institution { Faker::University.name }
  end
end
