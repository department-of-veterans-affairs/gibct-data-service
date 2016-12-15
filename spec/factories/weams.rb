# frozen_string_literal: true
FactoryGirl.define do
  sequence(:facility_code) do |n|
    n.to_s(32).rjust(8, '0')
  end

  sequence(:facility_code_ojt) do |n|
    fc = n.to_s(32).rjust(8, '0')
    fc[1] = '0'
    fc
  end

  sequence(:facility_code_public) do |n|
    fc = n.to_s(32).rjust(8, '0')
    fc[0, 2] = '11'
    fc
  end

  sequence(:facility_code_for_profit) do |n|
    fc = n.to_s(32).rjust(8, '0')
    fc[0, 2] = '21'
    fc
  end

  sequence(:facility_code_private) do |n|
    fc = n.to_s(32).rjust(8, '0')
    fc[0, 2] = '31'
    fc
  end

  factory :weam do
    institution { 'Some School' }
    facility_code { generate :facility_code }

    city { 'Cupcakes' }
    state { 'New York' }
    zip { '11203' }
    country 'USA'

    poo_status 'aprvd'
    applicable_law_code 'educational institution is approved for all chapters'

    institution_of_higher_learning_indicator 'Yes'
    ojt_indicator 'Yes'
    correspondence_indicator 'Yes'
    flight_indicator 'Yes'
    non_college_degree_indicator 'Yes'
    institution_type 'Public'

    # Facility_code second digit is 0
    trait :ojt do
      facility_code { generate(:facility_code_ojt) }
    end

    # Correspondence_indicator is true, flight_indicator is 'no',
    # and the other indicators do not matter
    trait :correspondence do
      facility_code { generate(:facility_code_private) }

      institution_of_higher_learning_indicator 'No'
      non_college_degree_indicator 'No'
    end

    # Flight_indicator is true other indicators are false
    trait :flight do
      facility_code { generate(:facility_code_private) }

      correspondence_indicator 'No'
      institution_of_higher_learning_indicator 'No'
      non_college_degree_indicator 'No'
    end

    # Not located in US
    trait :foreign do
      facility_code { generate(:facility_code_private) }

      country 'CAN'
      flight_indicator 'No'
      correspondence_indicator 'No'
    end

    # Public/state institutions
    trait :public do
      facility_code { enerate(:facility_code_public) }

      flight_indicator 'No'
      correspondence_indicator 'No'
    end

    # Schools that are private and for profit
    trait :for_profit do
      facility_code { facility_code_for_profit }

      flight_indicator 'No'
      correspondence_indicator 'No'
    end

    # private schools (not necessarily for profit)
    trait :private do
      facility_code { generate(:facility_code_private) }

      flight_indicator 'No'
      correspondence_indicator 'No'
    end

    # Fails approval because of poo_status
    trait :non_approved_poo do
      poo_status 'withdrn'
    end

    # Fails approval because of applicable_law_code
    trait :non_approved_applicable_law_code_not_approved do
      applicable_law_code 'educational institution is not approved'
    end

    # Fails approval because of applicable_law_code
    trait :non_approved_applicable_law_code_title_31 do
      applicable_law_code 'educational institution is approved for chapter 31 only'
    end

    # Fails approval because of all false indicators
    trait :non_approved_indicators do
      institution_of_higher_learning_indicator 'No'
      ojt_indicator 'No'
      correspondence_indicator 'No'
      flight_indicator 'No'
      non_college_degree_indicator 'No'
    end
  end
end
