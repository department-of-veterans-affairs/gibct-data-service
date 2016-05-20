FactoryGirl.define do
  factory :gibct_institution do
    sequence :institution_type_id do |n| n end
    sequence :facility_code do |n| "facility code #{n}" end
    sequence :institution do |n| "institution #{n}" end
    sequence :country do |n| "country #{n}" end
  end
end
