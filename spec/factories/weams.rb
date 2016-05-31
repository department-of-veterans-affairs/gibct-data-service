FactoryGirl.define do
  sequence(:facility_code) { |n| n.to_s(32).rjust(8, "0") }

  factory :weam do
    institution { Faker::University.name }
    facility_code { generate :facility_code }

    city { Faker::Address.city }
    state { DS::State.get_random_state.first[0] }
    zip { Faker::Address.zip }
    country 'USA'

    poo_status 'aprvd'
    applicable_law_code 'educational institution is approved for all chapters'

    institution_of_higher_learning_indicator 'Yes'
    ojt_indicator 'Yes'
    correspondence_indicator 'Yes'
    flight_indicator 'Yes'
    non_college_degree_indicator 'Yes'

    ###########################################################################
    ## ojt
    ## facility_code second digit is 0
    ###########################################################################    
    trait :ojt do
      sequence :facility_code do |n|
        fc = n.to_s(32).rjust(8, '0')
        fc[1] = '0'
        fc
      end
    end

    ###########################################################################
    ## correspondence
    ## correspondence_indicator is true, flight_indicator is 'no', and the
    ## other indicators do not matter
    ###########################################################################
    trait :correspondence do
      facility_code { x = generate(:facility_code); x[1] = '1'; x }
      institution_of_higher_learning_indicator 'No'
      non_college_degree_indicator 'No'
    end

    ###########################################################################
    ## flight
    ## flight_indicator is true other indicators are false
    ###########################################################################
    trait :flight do
      facility_code { x = generate(:facility_code); x[1] = '1'; x }
      correspondence_indicator 'No'
      institution_of_higher_learning_indicator 'No'
      non_college_degree_indicator 'No'
    end

    ###########################################################################
    ## foreign
    ## country is not 'USA'
    ###########################################################################
    trait :foreign do
      facility_code { x = generate(:facility_code); x[1] = '1'; x }

      country "CAN"
      flight_indicator 'No'
      correspondence_indicator 'No'
    end

    ###########################################################################
    ## public
    ## facility_code first digit is 1
    ###########################################################################    
    trait :public do
      facility_code { x = generate(:facility_code); x[0,2] = '11'; x }

      flight_indicator 'No'
      correspondence_indicator 'No'
    end


    ###########################################################################
    ## for_profit
    ## facility_code first digit is 2
    ###########################################################################    
    trait :for_profit do
       facility_code { x = generate(:facility_code); x[0,2] = '21'; x }

      flight_indicator 'No'
      correspondence_indicator 'No'
    end

    ###########################################################################
    ## private
    ## facility_code first digit is not 1 nor 2
    ###########################################################################    
    trait :private do
      facility_code { x = generate(:facility_code); x[0,2] = '31'; x }

      flight_indicator 'No'
      correspondence_indicator 'No'
    end

    ###########################################################################
    ## non_approved_poo
    ## Fails approval because of poo_status
    ########################################################################### 
    trait :non_approved_poo do
      poo_status 'withdrn'
    end

    ###########################################################################
    ## non_approved_applicable_law_code_not_approved
    ## Fails approval because of applicable_law_code
    ########################################################################### 
    trait :non_approved_applicable_law_code_not_approved do
      applicable_law_code 'educational institution is not approved'
    end

    ###########################################################################
    ## non_approved_applicable_law_code_title_31
    ## Fails approval because of applicable_law_code
    ########################################################################### 
    trait :non_approved_applicable_law_code_title_31 do
      applicable_law_code 'educational institution is approved for chapter 31 only'
    end


    ###########################################################################
    ## non_approved_indicators
    ## Fails approval because of all false indicators
    ########################################################################### 
    trait :non_approved_indicators do
      institution_of_higher_learning_indicator 'No'
      ojt_indicator 'No'
      correspondence_indicator 'No'
      flight_indicator 'No'
      non_college_degree_indicator 'No'
    end
  end
end
