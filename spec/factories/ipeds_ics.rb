FactoryGirl.define do
  factory :ipeds_ic do
    sequence :cross do |n| n.to_s(32).rjust(8, "0") end

    vet3 { (-2 .. -1).to_a.sample }
    vet4 { (-2 .. -1).to_a.sample }
    vet5 { (-2 .. -1).to_a.sample }
    vet2 { (-2 .. -1).to_a.sample }
    calsys { [-2, (1 .. 7).to_a.sample].sample }
    distnced { (-2 .. -1).to_a.sample }
  end
end
