FactoryGirl.define do
  factory :mou do
    institution { Faker::University.name }

    city { Faker::Address.city }
    sequence :state do |n| DS::State::STATES.keys[n % DS::State::STATES.keys.length] end
    sequence :ope do |n| n.to_s(32).rjust(8, "0") end

    dod_mou { ["", "", "", "", "", "Probation - DoD", "Title IV Non-Compliant"].sample }
  end
end
