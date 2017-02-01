FactoryGirl.define do
  factory :csv_file do
    transient do
      use_type true
    end

    after(:build) do |w, e|
      w.type = 'CsvFile' if e.use_type
    end

    after(:create) do |w, e|
      w.type = 'CsvFile' if e.use_type
    end
  end
end
