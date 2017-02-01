FactoryGirl.define do
  factory :vsoc do
    sequence(:facility_code) { |n| n.to_s(32).rjust(8, '0') }
    institution { Faker::University.name }

    vetsuccess_name { Faker::Name.name }
    vetsuccess_email { Faker::Internet.email }
  end
end
