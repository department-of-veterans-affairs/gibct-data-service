FactoryGirl.define do
  factory :mou do
    sequence(:ope) { |n| DS::OpeId.pad(n.to_s) }

    institution { Faker::University.name }
    status { ['Probation - DoD', 'Title IV Non-Compliant'].sample }

    trait :mou_probation do
      status 'Probation - DoD'
    end
  end
end
