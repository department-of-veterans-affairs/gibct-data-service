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

    agency_name 'American Physical Therapy Association, Commission on Accreditation in Physical Therapy Education'
    # accreditation_type => { accreditation_type: BaseConverter },
    # 'agency_name' => { agency_name: BaseConverter },
    # 'agency_status' => { agency_status: BaseConverter },
    # 'program_name' => { program_name: BaseConverter },
    # 'accreditation_status' => { accreditation_csv_status: BaseConverter },
    # 'accreditation_date_type' => { accreditation_date_type: BaseConverter },
    # 'periods' => { periods: BaseConverter },
    # 'last action' => { accreditation_status: BaseConverter }

    trait :by_campus do
      institution_name nil
      institution_ipeds_unitid nil
    end

    trait :by_institution do
      campus_name nil
      campus_ipeds_unitid nil
    end
  end
end
