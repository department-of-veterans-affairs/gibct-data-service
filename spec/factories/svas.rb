FactoryGirl.define do
  factory :sva do
    institution { Faker::University.name }

    sequence :cross do |n| n.to_s(32).rjust(6, "0") end

    city { Faker::Address.city }
    sequence :state do |n| DS_ENUM::State::STATES.keys[n % DS_ENUM::State::STATES.keys.length] end
    student_veteran_link { Faker::Internet.url("#{institution}.edu") }
  end
end
