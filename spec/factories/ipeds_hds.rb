FactoryGirl.define do
  factory :ipeds_hd do
    sequence :cross do |n| n.to_s(32).rjust(8, "0") end

    veturl { Faker::Internet.url }
  end
end
