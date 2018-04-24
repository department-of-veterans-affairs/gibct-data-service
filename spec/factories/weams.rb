# frozen_string_literal: true
FactoryGirl.define do
  factory :weam do
    institution { 'SOME SCHOOL' }
    facility_code { generate :facility_code }
    ope { generate :ope }

    country 'USA'
    state nil

    correspondence_indicator false
    flight_indicator false
    institution_of_higher_learning_indicator false
    non_college_degree_indicator false
    poo_status nil
    applicable_law_code nil
    ojt_indicator false
    approval_status nil

    # Facility_code second digit is 0
    trait :ojt do
      facility_code { generate(:facility_code_ojt) }
    end

    # Correspondence_indicator is true, flight_indicator is false,
    # and the other indicators do not matter
    trait :correspondence do
      facility_code { generate(:facility_code_private) }

      correspondence_indicator true
    end

    # Flight_indicator is true other indicators are false
    trait :flight do
      facility_code { generate(:facility_code_private) }

      flight_indicator true
    end

    # Not located in US
    trait :foreign do
      facility_code { generate(:facility_code_private) }

      country 'CAN'
    end

    # Public/state institutions
    trait :public do
      facility_code { generate(:facility_code_public) }
    end

    # Schools that are private and for profit
    trait :for_profit do
      facility_code { generate(:facility_code_for_profit) }
    end

    # private schools (not necessarily for profit)
    trait :private do
      facility_code { generate(:facility_code_private) }
    end

    trait :higher_learning do
      institution_of_higher_learning_indicator true
    end

    trait :ncd do
      non_college_degree_indicator true
    end

    trait :approved_poo_and_law_code do
      poo_status 'aprvd'
      applicable_law_code 'educational institution is approved for all chapters'
      approval_status 'Approved'
    end

    # Fails approval because of poo_status
    trait :withdrawn_poo do
      poo_status 'withdrn'
      applicable_law_code 'educational institution is approved for all chapters'
      approval_status 'Not approved'
    end

    # Fails approval because of applicable_law_code
    trait :approved_poo_and_non_approved_law_code do
      poo_status 'aprvd'
      applicable_law_code 'educational institution is not approved'
      approval_status 'Not approved'
    end

    # Fails approval because of applicable_law_code
    trait :approved_poo_and_law_code_title_31 do
      poo_status 'aprvd'
      applicable_law_code 'educational institution is approved for chapter 31 only'
      flight_indicator true
      approval_status 'Approved for chapter 31 only'
    end

    trait :with_flase_indicators do
      approval_status 'Not approved'
      institution_of_higher_learning_indicator false
      ojt_indicator false
      correspondence_indicator false
      flight_indicator false
      non_college_degree_indicator false
    end

    # Passes approval because of all false indicators
    trait :with_approved_indicators do
      institution_of_higher_learning_indicator true
      ojt_indicator true
      correspondence_indicator true
      flight_indicator true
      non_college_degree_indicator true
    end

    trait :institution_builder do
      facility_code '1ZZZZZZZ'
      poo_status 'aprvd'
      applicable_law_code 'educational institution is approved for all chapters'
      state 'NY'

      institution_of_higher_learning_indicator true
    end

    initialize_with do
      new(
        facility_code: facility_code, institution: institution, ope: ope, state: state,
        country: country, correspondence_indicator: correspondence_indicator,
        flight_indicator: flight_indicator, ojt_indicator: ojt_indicator,
        institution_of_higher_learning_indicator: institution_of_higher_learning_indicator,
        non_college_degree_indicator: non_college_degree_indicator,
        poo_status: poo_status, applicable_law_code: applicable_law_code,
        approval_status: approval_status
      )
    end
  end
end
