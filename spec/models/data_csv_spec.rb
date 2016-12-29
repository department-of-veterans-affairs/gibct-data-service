# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DataCsv, type: :model do
  describe 'version_exists?' do
    context 'at least one version exists' do
      before(:each) { create :data_csv, version: 1 }

      it 'returns true only if the version exists' do
        expect(DataCsv.version_exists?(1)).to be_truthy
        expect(DataCsv.version_exists?(2)).to be_falsy
      end
    end

    context 'the table is empty' do
      it 'returns false if no versions yet exist' do
        expect(DataCsv.version_exists?(1)).to be_falsy
      end
    end
  end

  describe 'next_version' do
    it 'returns 1 if the table is empty' do
      expect(DataCsv.next_version).to eq(1)
    end

    it 'returns the next highest version when the table is not empty' do
      create :data_csv
      expect(DataCsv.next_version).to eq(2)
    end
  end
end
