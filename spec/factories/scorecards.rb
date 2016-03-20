FactoryGirl.define do
  factory :scorecard do
    sequence :ope do |n| n.to_s(32).rjust(8, "0") end
    sequence :cross do |n| n.to_s(32).rjust(6, "0") end

    institution { Faker::University.name }
    insturl { Faker::Internet.url("#{institution}.edu") }
    pred_degree_awarded { Faker::Number.between(0, 4) }
    locale { [11, 12, 13, 21, 22, 23, 31, 32, 33, 41, 42, 43, 'NULL'].sample }
    undergrad_enrollment { [Faker::Number.between(1, 55000), Faker::Number.between(1, 55000), 'NULL'].sample }
    retention_all_students_ba { [Faker::Number.decimal(0, 9), Faker::Number.decimal(0, 9), 'NULL'].sample }
    retention_all_students_otb { [Faker::Number.decimal(0, 9), Faker::Number.decimal(0, 9), 'NULL'].sample }
    salary_all_students { [Faker::Number.between(1, 99000), Faker::Number.between(1, 55000), 'NULL'].sample }
    repayment_rate_all_students { [Faker::Number.decimal(0, 9), Faker::Number.decimal(0, 9), 'NULL'].sample }
    avg_stu_loan_debt { [Faker::Number.between(1, 50000), Faker::Number.between(1, 25000), 'NULL'].sample }
    c150_4_pooled_supp { [Faker::Number.decimal(0, 9), Faker::Number.decimal(0, 9), 'NULL'].sample }
    c200_l4_pooled_supp { [Faker::Number.decimal(0, 9), Faker::Number.decimal(0, 9), 'NULL'].sample }
  end
end
