FactoryGirl.define do
  factory :accreditation do

    institution_name { Faker::University.name }

    sequence :ope do |n| n.to_s(32).rjust(8, "0") end
    sequence :institution_ipeds_unitid do |n| n.to_s(32).rjust(6, "0") end

    campus_name { "#{institution_name} - #{Faker::Address.city}" }
    sequence :campus_ipeds_unitid do |n| n.to_s(32).rjust(6, "0") end

    csv_accreditation_type { ["Internship/Residency", "Institutional", "Specialized"].sample }
    agency_name { 
        key = Accreditation::ACCREDITATIONS.keys.sample
        "#{Accreditation::ACCREDITATIONS[key].sample} #{Faker::Lorem.word}" 
    }

    accreditation_status { "#{Accreditation::LAST_ACTIONS.sample}" }
    periods { 
        "#{Faker::Date.between(15.years.ago, Date.today)} - " + 
        "#{['Current', Faker::Date.between(1.years.ago, Date.today)].sample}" 
    }  
  end
end
