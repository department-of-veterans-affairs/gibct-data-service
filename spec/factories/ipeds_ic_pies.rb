FactoryGirl.define do
  factory :ipeds_ic_py do
    sequence :cross do |n| n.to_s(32).rjust(8, "0") end

    chg1py3 { rand(100000) }
    chg5py3 { rand(20000) }      
  end
end
