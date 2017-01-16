# frozen_string_literal: true
FactoryGirl.define do
  factory :scorecard do
    cross { generate :cross }

    pred_degree_awarded 0

    trait :c150_4_pooled_supp do
      c150_4_pooled_supp 1
      c150_l4_pooled_supp nil
    end

    trait :c150_l4_pooled_supp do
      c150_4_pooled_supp nil
      c150_l4_pooled_supp 1
    end

    trait :c150_4_pooled_supp_over_c150_l4_pooled_supp do
      c150_4_pooled_supp 1
      c150_l4_pooled_supp 2
    end
  end
end
