# frozen_string_literal: true

FactoryBot.define do
  factory :lce_license_and_cert, class: 'Lce::LicenseAndCert' do
    name { 'MyString' }
    fee { '9.99' }
    institution { nil }
  end
end
