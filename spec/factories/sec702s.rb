FactoryGirl.define do
  factory :sec702 do
    sequence(:state) { |n| DS::State::STATES.keys[n % DS::State::STATES.keys.length] }
    sec_702 %w(yes no).sample
  end
end
