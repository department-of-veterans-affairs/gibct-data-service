FactoryGirl.define do
  factory :raw_file_source do
    sequence :name do |i| "file_source_#{i}" end

    trait :no_name do
    	name nil
    end
  end
end
