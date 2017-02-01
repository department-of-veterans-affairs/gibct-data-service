FactoryGirl.define do
  factory :eight_key do
    institution { Faker::University.name }

    sequence(:ope) { |n| DS::OpeId.pad(n.to_s) }
    sequence(:cross) { |n| DS::IpedsId.pad(n.to_s) }
  end
end
