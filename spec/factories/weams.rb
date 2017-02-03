# frozen_string_literal: true
FactoryGirl.define do
  factory :weam do
    institution { 'SOME SCHOOL' }
    facility_code { generate :facility_code }
    ope { generate :ope }
    # cross { generate :cross }

    country 'USA'

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
    end

    # Fails approval because of poo_status
    trait :withdrawn_poo do
      poo_status 'withdrn'
      applicable_law_code 'educational institution is approved for all chapters'
    end

    # Fails approval because of applicable_law_code
    trait :approved_poo_and_non_approved_law_code do
      poo_status 'aprvd'
      applicable_law_code 'educational institution is not approved'
    end

    # Fails approval because of applicable_law_code
    trait :approved_poo_and_law_code_title_31 do
      poo_status 'aprvd'
      applicable_law_code 'educational institution is approved for chapter 31 only'
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
      facility_code 'ZZZZZZZZ'
      poo_status 'aprvd'
      applicable_law_code 'educational institution is approved for all chapters'
      institution_of_higher_learning_indicator true
    end
  end
end
