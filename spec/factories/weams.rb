FactoryGirl.define do
  factory :weam do
    institution { Faker::University.name }

    sequence :facility_code do |n| 
      n.to_s(32).rjust(8, "0") 
    end

    country 'USA'
    poo_status 'APRVD'
    applicable_law_code 'Educational Institution is Approved For All Chapters'

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
    ## correspondence_indicator is 'yes', flight_indicator is 'no', and the
    ## other indicators do not matter
    ###########################################################################
    trait :correspondence do
      sequence :facility_code do |n|
        fc = n.to_s(32).rjust(8, '0')
        fc[1] = '1'
        fc
      end
    end

    ###########################################################################
    ## flight
    ## flight_indicator is 'yes' other indicators are false
    ###########################################################################
    trait :flight do
      sequence :facility_code do |n|
        fc = n.to_s(32).rjust(8, '0')
        fc[1] = '1'
        fc
      end

      correspondence_indicator 'No'
    end

    ###########################################################################
    ## foreign
    ## country is not 'USA'
    ###########################################################################
    trait :foreign do
      country "CAN"

      sequence :facility_code do |n|
        fc = n.to_s(32).rjust(8, '0')
        fc[1] = '1'
        fc
      end

      flight_indicator 'No'
      correspondence_indicator 'No'
    end

    ###########################################################################
    ## public
    ## facility_code first digit is 1
    ###########################################################################    
    trait :public do
      sequence :facility_code do |n|
        fc = n.to_s(32).rjust(8, '0')
        fc[0] = '1'
        fc[1] = '1'
        fc
      end

      flight_indicator 'No'
      correspondence_indicator 'No'
    end


    ###########################################################################
    ## for_profit
    ## facility_code first digit is 2
    ###########################################################################    
    trait :for_profit do
      sequence :facility_code do |n|
        fc = n.to_s(32).rjust(8, '0')
        fc[0] = '2'
        fc[1] = '1'
        fc
      end

      flight_indicator 'No'
      correspondence_indicator 'No'
    end

    ###########################################################################
    ## private
    ## facility_code first digit is not 1 nor 2
    ###########################################################################    
    trait :private do
      sequence :facility_code do |n|
        fc = n.to_s(32).rjust(8, '0')
        fc[0] = '3'
        fc[1] = '1'
        fc
      end

      flight_indicator 'No'
      correspondence_indicator 'No'
    end

    ###########################################################################
    ## non_approved_poo
    ## Fails approval because of poo_status
    ########################################################################### 
    trait :non_approved_poo do
      poo_status 'WITHDRN'
    end

    ###########################################################################
    ## non_approved_applicable_law_code_not_approved
    ## Fails approval because of applicable_law_code
    ########################################################################### 
    trait :non_approved_applicable_law_code_not_approved do
      applicable_law_code 'Educational Institution is not Approved'
    end

    ###########################################################################
    ## non_approved_applicable_law_code_title_31
    ## Fails approval because of applicable_law_code
    ########################################################################### 
    trait :non_approved_applicable_law_code_title_31 do
      applicable_law_code 'Educational Institution is Approved for Chapter 31 Only'
    end


    ###########################################################################
    ## non_approved_indicators
    ## Fails approval because of all false indicators
    ########################################################################### 
    trait :non_approved_indicators do
      institution_of_higher_learning_indicator 'No'
      ojt_indicator 'No'
      correspondence_indicator 'No'
      flight_indicator ' No'
      non_college_degree_indicator 'No'
    end
  end
end
