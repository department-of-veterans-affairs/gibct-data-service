FactoryGirl.define do
  factory :scorecard do
    sequence :ope do |n| DS::OpeId.pad(n.to_s) end
    sequence :cross do |n| DS::IpedsId.pad(n.to_s) end

    institution { Faker::University.name }
    insturl { Faker::Internet.url("#{institution}.edu") }
    pred_degree_awarded { Faker::Number.between(0, 4) }
    locale { [11, 12, 13, 21, 22, 23, 31, 32, 33, 41, 42, 43].sample }
    undergrad_enrollment { Faker::Number.between(1, 55000) }
    retention_all_students_ba { Faker::Number.decimal(0, 9) }
    retention_all_students_otb { Faker::Number.decimal(0, 9) }
    salary_all_students { Faker::Number.between(1, 99000) }
    repayment_rate_all_students { Faker::Number.decimal(0, 9) }
    avg_stu_loan_debt { Faker::Number.between(1, 50000) }
    c150_4_pooled_supp { Faker::Number.decimal(0, 9) }
    c200_l4_pooled_supp { Faker::Number.decimal(0, 9) }
  end
end
