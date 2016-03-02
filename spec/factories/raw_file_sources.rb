FactoryGirl.define do
  factory :raw_file_source do
    sequence :name do |i| "file_source_#{i}" end
    build_order { (RawFileSource.all.maximum(:build_order) || 0) + 1 }

    trait :no_name do
      name nil
    end

    trait :no_order do
      build_order nil
    end
  end
end
