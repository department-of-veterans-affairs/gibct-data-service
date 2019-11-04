# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Storage, type: :model do
  def generate_csv_upload(name)
    ActionDispatch::Http::UploadedFile.new(
      tempfile: File.new(Rails.root.join('spec', 'fixtures', name)),
      filename: File.basename(name),
      type: 'text/csv'
    )
  end

  subject(:storage) { build :storage, user: user }

  let(:user) { create :user }

  describe 'when validating' do
    it 'has a valid factory' do
      expect(storage).to be_valid
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
        expect(storage.csv).to eq(storage.upload_file.original_filename)
      end
    end

    describe 'and reading files' do
      it 'reads the uploaded file when not persisted' do
        expect(storage.data).to eq(File.open(storage.upload_file.path).read)
      end
    end
  end

  describe 'when updating' do
    before do
      create :storage
    end

    let(:old) { described_class.first }
    let(:upload_file) { generate_csv_upload('weam_extra_column.csv') }
    let(:new_data) { File.read(params[:upload_file].path, encoding: 'ISO-8859-1') }
    let(:params) { { id: old.id, upload_file: upload_file, comment: old.comment, user: old.user } }

    it 'replaces the existing data, name, and comment' do
      described_class.find_and_update(params)
      expect(described_class.first.data).to eq(new_data)
    end

    it 'generates an error if the storage cannot be found' do
      params[:id] = 1_000_000
      expect { described_class.find_and_update(params) }.to raise_error(ArgumentError)
    end

    it 'requires a user' do
      params[:user] = nil
      expect(described_class.find_and_update(params).errors.full_messages).to eq(["User can't be blank"])
    end

    it 'requires an upload_file' do
      params[:upload_file] = nil
      expect(described_class.find_and_update(params).errors.full_messages).to eq(["Csv can't be blank"])
    end
  end
end
