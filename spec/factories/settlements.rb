FactoryGirl.define do
  factory :settlement do
    institution { Faker::University.name }
    sequence :cross do |n| DS::IpedsId.pad(n.to_s) end      

    settlement_description { "Settlement with U.S. Government" }    
  end
end
