# frozen_string_literal: true
require 'rails_helper'

RSpec.describe RawCsv, type: :model do
  subject { build :raw_csv }

  describe 'when validating' do
    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'requires a valid csv type' do
      expect(build(:raw_csv, csv_type: 'blah')).not_to be_valid
    end

    it 'requires a csv_file' do
      expect(build(:raw_csv, no_file: true)).not_to be_valid
    end

    it 'populates the storage with the uploaded csv' do
      data = File.open('spec/fixtures/weam.csv', 'rb').read
      expect(subject.storage).to eq(data)
    end
  end
end
