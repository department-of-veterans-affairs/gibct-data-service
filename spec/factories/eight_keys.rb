FactoryGirl.define do
  factory :eight_key do
    institution { Faker::University.name }

    sequence :ope do |n| DS::OpeId.pad(n.to_s) end
    sequence :cross do |n| DS::IpedsId.pad(n.to_s) end
  end
end
