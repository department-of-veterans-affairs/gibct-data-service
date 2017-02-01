FactoryGirl.define do
  factory :ipeds_ic_py do
    sequence(:cross) { |n| DS::IpedsId.pad(n.to_s) }

    chg1py3 { rand(100_000) }
    books { rand(20_000) }
  end
end
