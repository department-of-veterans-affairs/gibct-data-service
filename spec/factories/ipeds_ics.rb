# frozen_string_literal: true

FactoryGirl.define do
  factory :ipeds_ic do
    cross { generate :cross }
    vet2 1
    vet3 1
    vet4 1
    vet5 1
    distnced 1
    calsys 1

    trait :institution_builder do
      cross '999999'
    end

    initialize_with do
      new(cross: cross, vet2: vet2, vet3: vet3, vet4: vet4, vet5: vet5, distnced: distnced, calsys: calsys)
    end
  end
end
