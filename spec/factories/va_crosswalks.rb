FactoryGirl.define do
  factory :va_crosswalk do
    sequence :facility_code do |n| n.to_s(32).rjust(8, "0") end
    institution { Faker::University.name }

    sequence :ope do |n| DS::OpeId.pad(n.to_s) end
    sequence :cross do |n| DS::IpedsId.pad(n.to_s) end
  end
end
