FactoryGirl.define do
  factory :ipeds_ic_ay do
    sequence(:cross) { |n| DS::IpedsId.pad(n.to_s) }

    tuition_in_state { rand(50_000) }
    tuition_out_of_state { rand(50_000) }
    books { rand(10_000) }
  end
end
