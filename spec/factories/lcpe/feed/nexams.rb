FactoryBot.define do
  factory :lcpe_feed_nexam, class: 'Lcpe::Feed::Nexam' do
    facility_code { "MyString" }
    nexam_nm { "MyString" }
    descp_txt { "MyString" }
    fee_amt { "MyString" }
    begin_dt { "MyString" }
    end_dt { "MyString" }
  end
end
