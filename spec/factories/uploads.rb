# frozen_string_literal: true

FactoryBot.define do
  factory :upload do
    transient do
      fixture_path { 'spec/fixtures' }
      csv_name { 'weam.csv' }
      no_upload { false }
      skip_lines { 0 }
    end

    user

    csv_type { Weam.name }
    completed_at { Time.now.utc.to_fs(:db) }
    sequence :comment do |n|
      "Upload test #{n}"
    end

    upload_file do
      unless no_upload
        uf = Rack::Test::UploadedFile.new(
          "#{::Rails.root}/spec/fixtures/#{csv_name}",
          'text/csv'
        )

        uf.rewind
        uf
      end
    end

    initialize_with do
      new(csv_type: csv_type, upload_file: upload_file, comment: comment, user: user, skip_lines: skip_lines)
    end

    trait :valid_upload do
      ok { true }
    end

    trait :missing_required do
      ok { false }
    end

    trait :missing_upload do
      csv_type { Program.name }
      ok { false }
    end

    trait :scorecard_in_progress do
      csv_type { Scorecard.name }
      csv { Scorecard.name }
      ok { false }
      completed_at { nil }
    end

    trait :scorecard_finished do
      csv_type { Scorecard.name }
      csv { Scorecard.name }
      ok { true }
    end

    trait :census_lat_long do
      csv_type { CensusLatLong.name }
      csv { CensusLatLong.name }
      csv_name { 'census_lat_long.csv' }
      ok { true }
    end

    trait :failed_upload do
      csv_type { Scorecard.name }
      csv { Scorecard.name }
      ok { false }
      completed_at { nil }
    end

    trait :disabled_upload do
      csv_type { CipCode.name }
      csv { CipCode.name }
      ok { true }
    end

    factory :async_upload do
      transient do
        csv_name { 'program.csv' }
      end

      csv_type { Program.name }
      queued_at { Time.now.utc.to_fs(:db) }
      canceled_at { nil }
      
      trait :active do
        completed_at { nil }
      end

      trait :with_blob do
        active
        blob do
          rows = self.upload_file.read
          self.upload_file.rewind
          rows
        end
      end

      trait :canceled do
        completed_at { nil }
        canceled_at { (Time.now + 1.minute).utc.to_fs(:db) }
      end

      trait :dead do
        completed_at { nil }
        queued_at { (Time.now - 5.hours).utc.to_fs(:db) }
      end

      trait :complete_with_alerts do
        valid_upload
        status_message { "{\"csv_success\":{\"total_rows_count\":\"58\",\"valid_rows\":\"58\",\"failed_rows_count\":\"0\"},\"warning\":{}}" }
      end
    end
  end
end
