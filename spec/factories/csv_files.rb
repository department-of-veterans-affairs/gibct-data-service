# frozen_string_literal: true
include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :csv_file do
    user

    skip_lines_before_header 0
    skip_lines_after_header 0
    sequence(:name) { |n| "csv_file_#{n}.csv" }
    csv_type { CsvFile::TYPES.sample }

    factory :weam_csv_file do
      skip_lines_before_header 0
      skip_lines_after_header 1
      csv_type 'Weam'
      upload_file do
        ActionDispatch::TestProcess.fixture_file_upload('spec/fixtures/weams_test.csv', 'text/csv')
      end

      trait :missing_header do
        upload_file do
          ActionDispatch::TestProcess
            .fixture_file_upload('spec/fixtures/weams_missing_header_test.csv', 'text/csv')
        end
      end

      trait :missing_required_column do
        upload_file do
          ActionDispatch::TestProcess
            .fixture_file_upload('spec/fixtures/weams_missing_school_name_test.csv', 'text/csv')
        end
      end

      trait :extra_header do
        upload_file do
          ActionDispatch::TestProcess.fixture_file_upload('spec/fixtures/weams_extra_header_test.csv', 'text/csv')
        end
      end

      trait :duplicate_column do
        upload_file do
          ActionDispatch::TestProcess
            .fixture_file_upload('spec/fixtures/weams_duplicate_column_test.csv', 'text/csv')
        end
      end
    end

    factory :crosswalk_csv_file do
      skip_lines_before_header 0
      skip_lines_after_header 0
      csv_type 'Crosswalk'
      upload_file do
        ActionDispatch::TestProcess.fixture_file_upload('spec/fixtures/crosswalks_test.csv', 'text/csv')
      end

      trait :missing_header do
        upload_file do
          ActionDispatch::TestProcess
            .fixture_file_upload('spec/fixtures/crosswalks_missing_header_test.csv', 'text/csv')
        end
      end

      trait :missing_required_column do
        upload_file do
          ActionDispatch::TestProcess
            .fixture_file_upload('spec/fixtures/crosswalks_missing_facility_code_test.csv', 'text/csv')
        end
      end

      trait :extra_header do
        upload_file do
          ActionDispatch::TestProcess.fixture_file_upload('spec/fixtures/crosswalks_extra_header_test.csv', 'text/csv')
        end
      end

      trait :duplicate_column do
        upload_file do
          ActionDispatch::TestProcess
            .fixture_file_upload('spec/fixtures/crosswalks_duplicate_column_test.csv', 'text/csv')
        end
      end
    end
  end
end
