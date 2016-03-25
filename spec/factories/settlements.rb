FactoryGirl.define do
  factory :settlement do
    institution { Faker::University.name }
    sequence :cross do |n| n.to_s(32).rjust(8, "0") end

    settlement_description { "Settlement with U.S. Government" }    
  end
end
