FactoryGirl.define do
  factory :weam do
    sequence :facility_code do |n| n.to_s(32).rjust(8, "0") end
    institution { Faker::University.name }

    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip { Faker::Address.zip }
    country { Faker::Address.country_code }

    accredited { ['Y', 'Y', 'N', 'N', ' '].sample }
    poe { ['Y', 'N', 'N', 'N', ' '].sample }
    yr { ['Y', 'N', 'N', 'N', 'N'].sample }

    ojt_indicator { ['Yes', 'No'].sample }
    correspondence_indicator { ['Yes', 'No'].sample }
    flight_indicator { ['Yes', 'No'].sample }
    
    bah { Faker::Number.number(4).to_s }
  end
end
