# frozen_string_literal: true

FactoryBot.define do
  factory :upload do
    transient do
      fixture_path 'spec/fixtures'
      csv_name 'weam.csv'
      no_upload false
      skip_lines 0
    end

    user

    csv_type { Weam.name }
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
      ok true
    end

    trait :missing_required do
      ok false
    end

    trait :missing_upload do
      csv_type Program.name
      ok false
    end
  end
end
