# frozen_string_literal: true

FactoryBot.define do
  factory :lce_institution, class: 'Lce::Institution' do
    ptcpnt_id { 1 }
    name { 'MyString' }
    abbreviated_name { 'MyString' }
    physical_street { 'MyString' }
    physical_city { 'MyString' }
    physical_state { 'MyString' }
    physical_zip { 'MyString' }
    physical_country { 'MyString' }
    mailing_street { 'MyString' }
    mailing_city { 'MyString' }
    mailing_state { 'MyString' }
    mailing_zip { 'MyString' }
    mailing_country { 'MyString' }
    phone { 'MyString' }
    web_address { 'MyString' }
  end
end
