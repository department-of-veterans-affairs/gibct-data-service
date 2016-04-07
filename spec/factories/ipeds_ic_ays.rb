FactoryGirl.define do
  factory :ipeds_ic_ay do
    sequence :cross do |n| DS::IpedsId.pad(n.to_s) end

    tuition_in_state { rand(50000) }
    tuition_out_of_state { rand(50000) }  
    books { rand(10000) }
  end
end
