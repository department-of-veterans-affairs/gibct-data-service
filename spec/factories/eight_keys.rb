FactoryGirl.define do
  factory :eight_key do
    institution { Faker::University.name }

    city { Faker::Address.city }
    sequence :state do |n| DS_ENUM::State::STATES.keys[n % DS_ENUM::State::STATES.keys.length] end
    sequence :ope do |n| n.to_s(32).rjust(8, "0") end
    sequence :cross do |n| n.to_s(32).rjust(6, "0") end

    notes { Faker::Lorem.words }
  end
end
