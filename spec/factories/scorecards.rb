# frozen_string_literal: true
FactoryGirl.define do
  factory :scorecard do
    cross { generate :cross }

    pred_degree_awarded 0

    c150_4_pooled_supp 1
    c150_l4_pooled_supp 2

    trait :by_c150_4_pooled_supp do
      c150_4_pooled_supp 1
      c150_l4_pooled_supp nil
    end

    trait :by_c150_l4_pooled_supp do
      c150_4_pooled_supp nil
      c150_l4_pooled_supp 1
    end

    trait :institution_builder do
      cross '999999'
    end
  end
end
