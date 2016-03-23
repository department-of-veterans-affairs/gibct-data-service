FactoryGirl.define do
  factory :sva do
    institution { Faker::University.name }

    sequence :cross do |n| n.to_s(32).rjust(6, "0") end

    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    student_veteran_link { Faker::Internet.url("#{institution}.edu") }
  end
end
