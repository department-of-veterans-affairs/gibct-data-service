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

    # accreditation_type => { accreditation_type: BaseConverter },
    # 'agency_name' => { agency_name: BaseConverter },
    # 'agency_status' => { agency_status: BaseConverter },
    # 'program_name' => { program_name: BaseConverter },
    # 'accreditation_status' => { accreditation_csv_status: BaseConverter },
    # 'accreditation_date_type' => { accreditation_date_type: BaseConverter },
    # 'last action' => { accreditation_status: BaseConverter }

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
  end
end
