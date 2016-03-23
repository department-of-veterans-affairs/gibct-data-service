FactoryGirl.define do
  factory :sec702_csv_file do
    transient do
      use_type true
    end
    
    delimiter ','
    csv_data_file = File.new(Rails.root.join('spec/test_data', 'sec702_test.csv'))

    upload ActionDispatch::Http::UploadedFile.new(
      tempfile: csv_data_file, filename: File.basename(csv_data_file), 
      type: 'text/csv'
    )

    after(:build) do |w, e|
      w.type = nil if !e.use_type
      w.upload.rewind
    end

    after(:create) do |w, e|
      w.type = nil if !e.use_type
      w.upload.rewind
    end

    factory :sec702_csv_file_missing_header do
      csv_data_file = File.new(Rails.root.join('spec/test_data', 'sec702_test_missing_header.csv'))
      
      upload ActionDispatch::Http::UploadedFile.new(
        tempfile: csv_data_file, filename: File.basename(csv_data_file), 
        type: 'text/csv'
      )    
    end

    factory :sec702_csv_file_duplicate_state do
      csv_data_file = File.new(Rails.root.join('spec/test_data', 'sec702_test_duplicate_state.csv'))
      
      upload ActionDispatch::Http::UploadedFile.new(
        tempfile: csv_data_file, filename: File.basename(csv_data_file), 
        type: 'text/csv'
      )    
    end

    factory :sec702_csv_file_bad_state do
      csv_data_file = File.new(Rails.root.join('spec/test_data', 'sec702_test_bad_state.csv'))
      
      upload ActionDispatch::Http::UploadedFile.new(
        tempfile: csv_data_file, filename: File.basename(csv_data_file), 
        type: 'text/csv'
      )    
    end
  end
end