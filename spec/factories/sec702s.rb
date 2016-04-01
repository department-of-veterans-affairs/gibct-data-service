FactoryGirl.define do
  factory :sec702 do
    sequence :state do |n| DS::State::STATES.keys[n % DS::State::STATES.keys.length] end
    sec_702 ['yes', 'no'].sample
  end
end
