FactoryGirl.define do
  factory :ipeds_hd do
    sequence(:cross) { |n| DS::IpedsId.pad(n.to_s) }

    vet_tuition_policy_url { Faker::Internet.url }
  end
end
