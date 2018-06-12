# frozen_string_literal: true

FactoryGirl.define do
  factory :scorecard do
    cross { generate :cross }
    insturl { 'http://abc.123.com' }
    pred_degree_awarded 0
    locale 11
    undergrad_enrollment 12_345
    retention_all_students_ba 123.45
    retention_all_students_otb 543.21
    salary_all_students 100
    repayment_rate_all_students 0.12_345
    avg_stu_loan_debt 1_000_000

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

    initialize_with do
      new(
        cross: cross, insturl: insturl, pred_degree_awarded: pred_degree_awarded,
        locale: locale, undergrad_enrollment: undergrad_enrollment,
        retention_all_students_ba: retention_all_students_ba,
        retention_all_students_otb: retention_all_students_otb,
        salary_all_students: salary_all_students,
        repayment_rate_all_students: repayment_rate_all_students,
        avg_stu_loan_debt: avg_stu_loan_debt, c150_4_pooled_supp: c150_4_pooled_supp,
        c150_l4_pooled_supp: c150_l4_pooled_supp
      )
    end
  end
end
