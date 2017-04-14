# frozen_string_literal: true
FactoryGirl.define do
  factory :upload do
    transient do
      fixture_path 'spec/fixtures'
      csv_name 'weam.csv'
      no_upload false
      skip_lines 0
    end

    user

    csv_type { 'Weam' }
    sequence :comment do |n|
      "Upload test #{n}"
    end

    upload_file do
      unless no_upload
        uf = ActionDispatch::Http::UploadedFile.new(
          tempfile: File.new(Rails.root.join(fixture_path, csv_name)),
          filename: File.basename(csv_name),
          type: 'text/csv'
        )

        uf.rewind
        uf
      end
    end

    initialize_with do
      new(csv_type: csv_type, upload_file: upload_file, comment: comment, user: user, skip_lines: skip_lines)
    end
  end
end
