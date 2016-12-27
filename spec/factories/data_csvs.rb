# frozen_string_literal: true
FactoryGirl.define do
  factory :data_csv do
    sequence(:version) { |n| n }
  end
end
