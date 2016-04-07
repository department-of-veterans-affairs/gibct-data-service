FactoryGirl.define do
  factory :ipeds_hd do
    sequence :cross do |n| DS::IpedsId.pad(n.to_s) end

    vet_tuition_policy_url { Faker::Internet.url }
  end
end
