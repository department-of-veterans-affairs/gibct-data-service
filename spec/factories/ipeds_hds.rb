FactoryGirl.define do
  factory :ipeds_hd do
    cross { generate :cross }
    vet_tuition_policy_url 'http://example.com'
  end
end
