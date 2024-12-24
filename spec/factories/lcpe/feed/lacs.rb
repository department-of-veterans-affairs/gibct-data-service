FactoryBot.define do
  factory :lcpe_feed_lac, class: 'Lcpe::Feed::Lac' do
    facility_code { "MyString" }
    edu_lac_type_nm { "MyString" }
    lac_nm { "MyString" }
    test_nm { "MyString" }
    fee_amt { "MyString" }
  end
end
