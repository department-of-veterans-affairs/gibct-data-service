FactoryGirl.define do
  factory :va_crosswalk do
    sequence(:facility_code) { |n| n.to_s(32).rjust(8, '0') }
    institution { Faker::University.name }

    sequence(:ope) { |n| DS::OpeId.pad(n.to_s) }
    sequence(:cross) { |n| DS::IpedsId.pad(n.to_s) }
  end
end
