FactoryGirl.define do
  factory :ipeds_ic_ay do
    sequence :cross do |n| n.to_s(32).rjust(8, "0") end

    chg2ay3 { rand(50000) }
    chg3ay3 { rand(50000) }  
    chg4ay3 { rand(10000) }
  end
end
