# frozen_string_literal: true

FactoryBot.define do
  factory :school_closure do
    facility_code { generate :facility_code }

    institution_name 'SOME SCHOOL'
    school_closing true
    school_closing_date Time.zone.today.strftime('%m/%d/%y')
    school_closing_on Time.zone.today
    school_closing_message 'This school is closing soon'
    notes 'Some notes'

    trait :institution_builder do
      facility_code '1ZZZZZZZ'
    end
  end
end
