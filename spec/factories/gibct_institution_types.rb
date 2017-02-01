FactoryGirl.define do
  factory :gibct_institution_type do
    sequence(:name) { |n| "institution_type_#{n}" }
  end
end
