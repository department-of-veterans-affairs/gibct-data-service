FactoryGirl.define do
  factory :ipeds_ic_py do
    sequence :cross do |n| DS::IpedsId.pad(n.to_s) end

    chg1py3 { rand(100000) }
    books { rand(20000) }      
  end
end
