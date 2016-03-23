FactoryGirl.define do
  factory :sec702 do
    sequence :state do |n| DS_ENUM::State::STATES.keys[n % DS_ENUM::State::STATES.keys.length] end
    sec_702 ['yes', 'no'].sample
  end
end
