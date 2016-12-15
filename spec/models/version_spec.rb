# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Version, type: :model do
  describe 'validates' do
    subject { build :version }

    let(:bad_version) { build :version, number: 123.4 }
    let(:no_version) { build :version, number: nil }
    let(:no_by) { build :version, approved_on: DateTime.current, by: nil }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'requires an integer number' do
      expect(no_version).not_to be_valid
      expect(bad_version).not_to be_valid
    end

    it 'requires a valid or nil approved_on' do
      subject.approved_on = '32423423dsat34'
      expect(subject).not_to be_valid
    end

    it 'requires an by if the approval_date is not nil' do
      expect(no_by).not_to be_valid
    end
  end

  describe 'production and preview versions' do
    before(:each) do
      create :version, number: 1, approved_on: 3.days.ago
      create :version, number: 2, created_at: 2.days.ago
      create :version, number: 3, approved_on: 1.days.ago
      create :version, number: 4, created_at: 0.days.ago
    end

    it 'can find the latest production_version' do
      expect(Version.production_version).to eq(3)
    end

    it 'can find the latest preview_version' do
      expect(Version.preview_version).to eq(4)
    end

    it 'can find the production_version on a given date and time as string' do
      expect(Version.production_version_at(2.days.ago.to_s)).to eq(1)
    end

    it 'can find the production_version on a given date and time as Time' do
      expect(Version.production_version_at(2.days.ago)).to eq(1)
    end

    it 'can find the preview_version on a given date and time as string' do
      expect(Version.preview_version_at(1.day.ago.to_s)).to eq(2)
    end

    it 'can find the production_version on a given date and time as Time' do
      expect(Version.preview_version_at(1.day.ago)).to eq(2)
    end
  end
end
