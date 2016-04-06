FactoryGirl.define do
  factory :p911_yr do
    sequence :facility_code do |n| n.to_s(32).rjust(8, "0") end
    institution { Faker::University.name }

    p911_yr_recipients { Faker::Number.between(1, 3000) }
    p911_yellow_ribbon { Faker::Number.decimal(9) }    
  end
end
