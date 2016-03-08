FactoryGirl.define do
  factory :school_file do
    transient do
      use_name true
      use_source true
      use_type true
      use_upload true
    end

    upload_date { DateTime.current }
    association :raw_file_source, factory: :school_file_source

    after(:build) do |w, e|
      w.type = nil if !e.use_type
      w.upload_date = nil if !e.use_upload
      w.raw_file_source = nil if !e.use_source
      w.name = w.to_server_name if e.use_name
    end

    after(:create) do |w, e|
      w.name = w.to_server_name if e.use_name
    end
  end
end