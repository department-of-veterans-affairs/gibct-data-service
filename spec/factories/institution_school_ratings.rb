# frozen_string_literal: true

FactoryBot.define do
  factory :institution_school_rating do
    survey_key { '20221219GIBILL018591TEST1' }
    age { '22' }
    gender { 'FEMALE' }
    school { 'UTAH VALLEY UNIVERSITY' }
    facility_code { '11913105' }
    degree { 'BA ADMINSITRATION MANAGEMENT CONCENTRATION' }
    graduation_date { Date.parse('2021-08-17') }
    benefit_program { 'CHAPTER 35' }
    enrollment_type { 'IN-PERSON' }
    monthly_payment_benefit { '1' }
    payee_number { 'Spouse - 42' }
    objective_code { 'Bachelors - 25' }
    response_date { Date.parse('2022-12-20') }
    sent_date { Date.parse('2022-12-19') }
    q1 { 1 }
    q2 { 1 }
    q3 { 1 }
    q4 { 1 }
    q5 { 1 }
    q6 { 'Yes' }
    q7 { 1 }
    q8 { 1 }
    q9 { 1 }
    q10 { 1 }
    q11 { 1 }
    q12 { 1 }
    q13 { 1 }
    q14 { 1 }
  end

  trait :second_rating do
    q1 { 3 }
    q2 { 2 }
    q3 { 3 }
    q4 { 4 }
    q5 { 3 }
    q6 { 'Yes' }
    q7 { 3 }
    q8 { 1 }
    q9 { 3 }
    q10 { 3 }
    q11 { 2 }
    q12 { 3 }
    q13 { 3 }
    q14 { 3 }
  end

  trait :third_rating do
    q1 { 2 }
    q2 { 3 }
    q3 { 2 }
    q4 { 1 }
    q5 { 2 }
    q6 { 'Yes' }
    q7 { 2 }
    q8 { 4 }
    q9 { 2 }
    q10 { 2 }
    q11 { 3 }
    q12 { 2 }
    q13 { 2 }
    q14 { 2 }
  end

  # nil, negative and 0 are not counted
  trait :nil_rating do
    q1 { nil }
    q2 { nil }
    q3 { nil }
    q4 { -3 }
    q5 { nil }
    q6 { 'Yes' }
    q7 { -4 }
    q8 { nil }
    q9 { nil }
    q10 { 0 }
    q11 { nil }
    q12 { nil }
    q13 { nil }
    q14 { 3 }
  end

  trait :greater_than_4_rating do
    q1 { 5 }
    q2 { 7 }
    q3 { 6 }
    q4 { 4 }
    q5 { 8 }
    q6 { 'Yes' }
    q7 { 10 }
    q8 { 4 }
    q9 { 5 }
    q10 { 6 }
    q11 { 7 }
    q12 { 8 }
    q13 { 9 }
    q14 { 4 }
  end
end
