FactoryGirl.define do
  factory :sec702_school do
    sequence(:facility_code) { |n| n.to_s(32).rjust(8, '0') }
    sec_702 %w(yes no).sample
  end
end
