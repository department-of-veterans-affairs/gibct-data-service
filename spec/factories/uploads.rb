# frozen_string_literal: true
FactoryGirl.define do
  factory :upload do
    transient do
      fixture_path 'spec/fixtures'
      csv 'weam.csv'
      no_upload false
    end

    user

    csv_type { InstitutionBuilder::TABLES.first.name }
    sequence :comment do |n|
      "Upload test #{n}"
    end

    after(:build) do |upload, evaluator|
      unless evaluator.no_upload
        upload.upload_file = ActionDispatch::Http::UploadedFile.new(
          tempfile: File.new(Rails.root.join(evaluator.fixture_path, evaluator.csv)),
          filename: File.basename(evaluator.csv),
          type: 'text/csv'
        )

        upload.upload_file.rewind
      end
    end
  end
end
