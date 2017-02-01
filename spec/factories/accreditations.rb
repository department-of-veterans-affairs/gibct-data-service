FactoryGirl.define do
  factory :accreditation do
    institution_name { 'Some Name' }

    sequence(:ope) { |n| DS::OpeId.pad(n.to_s) }
    sequence(:institution_ipeds_unitid) { |n| DS::IpedsId.pad(n.to_s) }

    campus_name { "#{institution_name} - #{Faker::Address.city}" }
    sequence(:campus_ipeds_unitid) { |n| DS::IpedsId.pad(n.to_s) }

    agency_name do
      key = Accreditation::ACCREDITATIONS.keys.sample
      "#{Accreditation::ACCREDITATIONS[key].sample} #{Faker::Lorem.word}"
    end

    accreditation_status { Accreditation::LAST_ACTIONS.sample.to_s }
    periods do
      "#{Faker::Date.between(15.years.ago, Time.current.to_date)} - Current"
    end

    csv_accreditation_type 'INSTITUTIONAL'

    trait :not_current do
      periods 'Something not ...'
    end

    trait :not_institutional do
      csv_accreditation_type do
        Accreditation::CSV_ACCREDITATION_TYPES.reject do |a|
          a == 'INSTITUTIONAL'
        end.sample
      end
    end

    trait :accreditation_status_nil do
      accreditation_status nil
    end
  end
end
