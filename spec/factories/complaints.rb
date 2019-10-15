# frozen_string_literal: true

FactoryBot.define do
  factory :complaint do
    facility_code { generate :facility_code }
    ope { generate :ope }

    status { 'closed' }
    closed_reason { 'resolved' }
    issues { nil }

    trait :all_issues do
      issues { %w[
        FinanCial QUALITY RefuND REcruiT Accreditation deGree LOANS GraDe TranSFer jOb TranScript oTHER
      ].join(' ') }
    end

    trait :institution_builder do
      facility_code { '1ZZZZZZZ' }
      ope { '00279100' }
    end

    initialize_with do
      new(
        facility_code: facility_code, ope: ope, status: status,
        closed_reason: closed_reason, issues: issues
      )
    end
  end
end
