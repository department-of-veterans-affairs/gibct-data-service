FactoryGirl.define do
  factory :complaint do
    sequence(:facility_code) { |n| n.to_s(32).rjust(8, '0') }
    institution { Faker::University.name }

    sequence :ope, &:to_s

    status { Complaint::STATUSES.sample }
    closed_reason { Complaint::CLOSED_REASONS.sample }

    issue do
      %w(
        Financial Quality Refund Recruit Accreditation
        Degree Loans Grade Transfer Job Transcript Other).sample
    end

    trait :not_ok_to_sum do
      status 'pending'
    end

    trait :ok_to_sum do
      status 'closed'
      closed_reason 'resolved'
    end

    trait :all_issues do
      status 'closed'
      closed_reason 'resolved'

      issue %w(
        Financial Quality Refund Recruit Accreditation
        Degree Loans Grade Transfer Job Transcript Other).join(' ')
    end
  end
end
