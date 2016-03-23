FactoryGirl.define do
  factory :weam do
    sequence :facility_code do |n| n.to_s(32).rjust(8, "0") end
    institution { Faker::University.name }

    city { Faker::Address.city }
    sequence :state do |n| DS_ENUM::State::STATES.keys[n % DS_ENUM::State::STATES.keys.length] end
    zip { Faker::Address.zip }
    country { Faker::Address.country_code }

    accredited { ['Y', 'Y', 'N', 'N', ' '].sample }
    poe { ['Y', 'N', 'N', 'N', ' '].sample }
    yr { ['Y', 'N', 'N', 'N', 'N'].sample }

    ojt_indicator { ['Yes', 'No'].sample }
    correspondence_indicator { ['Yes', 'No'].sample }
    flight_indicator { ['Yes', 'No'].sample }
    
    bah { Faker::Number.number(4).to_s }

    trait :foreign do
      country { "CAN" }
      ojt_indicator { 'Yes' }
      correspondence_indicator { 'Yes' }
      flight_indicator { 'Yes' } 
    end

    trait :flight do
      country { "USA" }
      ojt_indicator { 'Yes' }
      correspondence_indicator { 'Yes' }
      flight_indicator { 'Yes' } 
    end

    trait :correspondence do
      country { "USA" }
      ojt_indicator { 'Yes' }
      correspondence_indicator { 'Yes' }
      flight_indicator { 'No' } 
    end

    trait :ojt do
      country { "USA" }
      ojt_indicator { 'Yes' }
      correspondence_indicator { 'No' }
      flight_indicator { 'No' } 
    end

    trait :public do
      sequence :facility_code do |n| "1" + n.to_s(32).rjust(7, "0") end
      country { "USA" }
      ojt_indicator { 'No' }
      correspondence_indicator { 'No' }
      flight_indicator { 'No' } 
    end

    trait :for_profit do
      sequence :facility_code do |n| "2" + n.to_s(32).rjust(7, "0") end
      country { "USA" }
      ojt_indicator { 'No' }
      correspondence_indicator { 'No' }
      flight_indicator { 'No' } 
    end

    trait :private do
      sequence :facility_code do |n| "3" + n.to_s(32).rjust(7, "0") end
      country { "USA" }
      ojt_indicator { 'No' }
      correspondence_indicator { 'No' }
      flight_indicator { 'No' } 
    end
  end
end
