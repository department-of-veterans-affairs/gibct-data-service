FactoryGirl.define do
  factory :sec702_school do
    sequence :facility_code do |n| n.to_s(32).rjust(8, "0") end
    sec_702 ['yes', 'no'].sample    
  end
end
