# frozen_string_literal: true

FactoryGirl.define do
  factory :accreditation do
    sequence :institution_name do |n|
      "Institution #{n}"
    end

    sequence :campus_name do |n|
      "Campus #{n}"
    end

    ope { generate :ope }
    institution_ipeds_unitid { generate :cross }
    campus_ipeds_unitid { generate :cross }

    agency_name 'sticky wicket acupuncture association'
    periods '01/01/2016 - current'
    csv_accreditation_type 'institutional'
    accreditation_status 'Resigned'

    trait :by_campus do
      institution_name nil
      institution_ipeds_unitid nil
    end

    trait :by_institution do
      campus_name nil
      campus_ipeds_unitid nil
    end

    trait :institution_builder do
      campus_ipeds_unitid '999999'
    end

    initialize_with do
      new(
        institution_name: institution_name, campus_name: campus_name,
        ope: ope, institution_ipeds_unitid: institution_ipeds_unitid,
        campus_ipeds_unitid: campus_ipeds_unitid, agency_name: agency_name,
        periods: periods, csv_accreditation_type: csv_accreditation_type,
        accreditation_status: accreditation_status
      )
    end
  end
end
