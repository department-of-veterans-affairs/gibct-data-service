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
    col_sep { ',' }

    csv_type { Weam.name }
    completed_at { Time.now.utc.to_s(:db) }
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

    trait :calculator_constant do
      csv_type { CalculatorConstant.name }
      csv { CalculatorConstant.name }
      ok { true }
    end
  end
end
