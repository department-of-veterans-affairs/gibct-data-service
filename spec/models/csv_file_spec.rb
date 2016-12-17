# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CsvFile, type: :model do
  describe 'when validating' do
    subject { build :csv_file }

    let(:no_user) { build :csv_file, user: nil }
    let(:no_name) { build :csv_file, name: nil }
    let(:invalid_type) { build :csv_file, csv_type: 'Fred' }
    let(:no_type) { build :csv_file, csv_type: nil }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'requires an uploading user' do
      expect(no_user).not_to be_valid
    end

    it 'requires an original filename' do
      expect(no_name).not_to be_valid
    end

    it 'requires a valid type' do
      expect(invalid_type).not_to be_valid
      expect(no_type).not_to be_valid
    end
  end

  describe 'when saving' do
    subject { build :csv_file }

    it 'does not update an existing record' do
      expect(subject.save).to be_truthy
      expect { subject.save }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end

  describe 'when uploading a file' do
    subject { build :csv_file, :weam }

    before(:each) { create_list :weam, 5 }

    it 'gets the CSV model from the csv_type' do
      expect(subject.model_from_csv_type).to eq(Weam)
    end

    it "deletes the data from the CSV model's table" do
      expect { subject.prep_load }.to change { Weam.all.length }.from(5).to(0)
    end

    it 'gets the row data from the CSV file' do
      expect(subject.data_from_csv_file).to be_present
    end

    it 'gets the headers from the row data' do
      # approved is a derived field and not present in the csv
      headers = Weam::HEADER_MAP.keys
      expect(subject.headers_from_csv_file).to match_array(headers)
    end

    it 'raises an error if any headers are missing' do
      missing_header_csv = build :csv_file, :weam, :weam_missing_header
      expect { missing_header_csv.check_headers }.to raise_error(StandardError)
    end

    it "loads each row into the CSV model's table" do
      expect { subject.save }.to change { Weam.all.length }.from(5).to(3)
    end
  end
end
