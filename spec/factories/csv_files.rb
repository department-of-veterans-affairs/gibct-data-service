# frozen_string_literal: true
include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :csv_file do
    sequence(:name) { |n| "csv_file_#{n}.csv" }
    sequence(:user) { |n| "homer_simpson#{n}@va.gov" }

    csv_type { CsvFile::TYPES.sample }

    trait :weam do
      skip_lines_before_header 0
      skip_lines_after_header 1
      upload_file { ActionDispatch::TestProcess.fixture_file_upload('spec/fixtures/weams_test.csv', 'text/csv') }
      csv_type 'Weam'
    end

    trait :weam_missing_header do
      upload_file do
        ActionDispatch::TestProcess.fixture_file_upload('spec/fixtures/weams_missing_header_test.csv', 'text/csv')
      end
    end
  end
end
