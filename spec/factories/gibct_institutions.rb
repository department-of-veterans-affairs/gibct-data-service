FactoryGirl.define do
  factory :gibct_institution do
    sequence(:institution_type_id) { |n| n }
    sequence(:facility_code) { |n| "facility code #{n}" }
    sequence(:institution) { |n| "institution #{n}" }
    sequence(:country) { |n| "country #{n}" }
  end
end
