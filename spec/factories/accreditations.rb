FactoryGirl.define do
  factory :accreditation do

    institution_name { Faker::University.name }

    sequence :ope do |n| DS::OpeId.pad(n.to_s) end
    sequence :institution_ipeds_unitid do |n| DS::IpedsId.pad(n.to_s) end

    campus_name { "#{institution_name} - #{Faker::Address.city}" }
    sequence :campus_ipeds_unitid do |n| DS::IpedsId.pad(n.to_s) end

    agency_name { 
        key = Accreditation::ACCREDITATIONS.keys.sample
        "#{Accreditation::ACCREDITATIONS[key].sample} #{Faker::Lorem.word}" 
    }

    accreditation_status { "#{Accreditation::LAST_ACTIONS.sample}" }
    periods { 
        "#{Faker::Date.between(15.years.ago, Date.today)} - Current" 
    }

    csv_accreditation_type 'INSTITUTIONAL'

    trait :not_current do
      periods 'Something not ...'
    end

    trait :not_institutional do
      csv_accreditation_type { 
        Accreditation::CSV_ACCREDITATION_TYPES.reject { 
            |a| a == 'INSTITUTIONAL' 
        }.sample 
      }
    end

    trait :accreditation_status_nil do
      accreditation_status nil
    end
  end
end
