# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Storage, type: :model do
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
end
