FactoryBot.define do
  factory :license_certification_institution, class: 'LicenseCertification::Institution' do
    name { "MyString" }
    abbreviated_name { "MyString" }
    physical_street { "MyString" }
    physical_city { "MyString" }
    physical_zip { "MyString" }
    physical_country { "MyString" }
    mailing_street { "MyString" }
    mailing_city { "MyString" }
    mailing_zip { "MyString" }
    mailing_country { "MyString" }
    phone { "MyString" }
    web_address { "MyString" }
  end
end
