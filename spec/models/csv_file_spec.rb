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

  describe 'when getting defaults' do
    CsvFile::TYPES.each do |type|
      it "returns the skipped line parameters and default delimiter for #{type}" do
        defaults = described_class.defaults_for(type)
        expect(defaults.keys).to include('skip_lines_before_header', 'skip_lines_after_header', 'delimiter')
      end
    end
  end

  describe 'when getting upload times' do
    let(:csv_types) { CsvFile::TYPES.map { |t| t.name.underscore } }

    let(:today) { 0.days.ago.beginning_of_day }
    let(:yesterday) { 1.day.ago.beginning_of_day }

    before(:each) do
      csv_types.each do |t|
        factory = "#{t.underscore}_csv_file".to_sym

        create factory, :missing_header, created_at: yesterday
        create factory, :missing_header, created_at: today
        create factory, created_at: yesterday
        create factory, created_at: today
      end
    end

    it 'gets the latest sucessful upload times' do
      last_uploads = CsvFile.last_uploads(true)

      expect(last_uploads.map(&:csv_type).uniq).to match_array(CsvFile::TYPES.map(&:name))
      expect(last_uploads.map(&:created_at)).to RSpec::Matchers::BuiltIn::All.new(eq(today))
    end

    it 'gets the latest failed upload times' do
      last_uploads = CsvFile.last_uploads(false)

      expect(last_uploads.map(&:csv_type).uniq).to match_array(CsvFile::TYPES.map(&:name))
      expect(last_uploads.map(&:created_at)).to RSpec::Matchers::BuiltIn::All.new(eq(today))
    end
  end

  describe 'when saving' do
    subject { build :csv_file }

    it 'does not update an existing record' do
      expect(subject.save).to be_truthy
      expect { subject.save }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end

  CsvFile::TYPES.each do |type|
    type_factory = type.name.underscore

    describe "when uploading a #{type} file" do
      subject { build "#{type_factory}_csv_file".to_sym }

      before(:each) { create_list type_factory.to_sym, 5 }

      it "loads each row into the CSV model's table" do
        expect { subject.save }.to change { type.all.length }.from(5).to(3)
        expect(subject.result).to eq('Successful')
      end

      it 'raises an error if any headers are missing' do
        missing_header_csv_file = create "#{type_factory}_csv_file".to_sym, :missing_header

        expect(missing_header_csv_file.result).to eq('Failed')
        expect(missing_header_csv_file.errors.any?).to be_truthy
      end

      it 'raises an error if a row of data cannot be saved' do
        missing_required_column_csv_file = create "#{type_factory}_csv_file".to_sym, :missing_required_column

        expect(missing_required_column_csv_file.result).to eq('Failed')
        expect(missing_required_column_csv_file.errors.any?).to be_truthy
      end

      it 'raises an error if extra headers are found' do
        extra_header_csv_file = create "#{type_factory}_csv_file".to_sym, :extra_header

        expect(extra_header_csv_file.result).to eq('Failed')
        expect(extra_header_csv_file.errors.any?).to be_truthy
      end

      it 'raises an error if a duplcate column is found' do
        extra_header_csv_file = create "#{type_factory}_csv_file".to_sym, :duplicate_column

        expect(extra_header_csv_file.result).to eq('Failed')
        expect(extra_header_csv_file.errors.any?).to be_truthy
      end
    end
  end
end
