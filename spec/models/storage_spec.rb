# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Storage, type: :model do
  def generate_csv_upload(name)
    ActionDispatch::Http::UploadedFile.new(
      tempfile: File.new(Rails.root.join('spec/fixtures', name)),
      filename: File.basename(name),
      type: 'text/csv'
    )
  end

  subject { build :storage }

  describe 'when validating' do
    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'requires the requesting user' do
      expect(build(:storage, user: nil)).not_to be_valid
    end

    it 'requires an upload_file to produce a filename' do
      expect(build(:storage, no_upload: true)).not_to be_valid
    end

    it 'requires a csv_type' do
      expect(build(:storage, csv_type: nil)).not_to be_valid
    end

    describe 'and deriving columns' do
      it 'initializes csv column when not persisted' do
        expect(subject.csv).to eq(subject.upload_file.original_filename)
      end
    end

    describe 'and reading files' do
      it 'reads the uploaded file when not persisted' do
        expect(subject.data).to eq(File.open(subject.upload_file.path).read)
      end
    end
  end

  describe 'when updating' do
    before(:each) do
      create :storage
    end

    let(:old_storage) { Storage.first }

    let(:params) do
      {
        id: old_storage.id, upload_file: generate_csv_upload('weam_extra_column.csv'),
        comment: 'replace', user: old_storage.user
      }
    end

    let(:data) { File.read(params[:upload_file].path, encoding: 'ISO-8859-1') }

    it 'replaces the existing data, name, and comment' do
      Storage.find_and_update(params)

      new_storage = Storage.first
      expect(new_storage.data).not_to eq(old_storage.data)
      expect(new_storage.csv).not_to eq(old_storage.csv)
      expect(new_storage.comment).not_to eq(old_storage.comment)
    end

    it 'generates an error if the storage cannot be found' do
      params[:id] = 1_000_000
      expect { Storage.find_and_update(params) }.to raise_error(ArgumentError)
    end

    it 'requires a user' do
      params[:user] = nil
      expect(Storage.find_and_update(params).errors.full_messages).to eq(["User can't be blank"])
    end

    it 'requires an upload_file' do
      params[:upload_file] = nil
      expect(Storage.find_and_update(params).errors.full_messages).to eq(["Csv can't be blank"])
    end
  end
end
