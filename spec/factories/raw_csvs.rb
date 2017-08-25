# frozen_string_literal: true
FactoryGirl.define do
  factory :raw_csv do
    transient do
      fixture_path 'spec/fixtures'
      no_file false
      csv_class_name 'Weam'
      csv_file_name 'weam.csv'
    end

    csv_type { csv_class_name }

    csv_file do
      unless no_file
        uf = ActionDispatch::Http::UploadedFile.new(
          tempfile: File.new(Rails.root.join(fixture_path, csv_file_name)),
          filename: File.basename(csv_file_name),
          type: 'text/csv'
        )

        uf.rewind
        uf
      end
    end

    initialize_with do
      new(csv_type: csv_type, csv_file: csv_file)
    end
  end
end
