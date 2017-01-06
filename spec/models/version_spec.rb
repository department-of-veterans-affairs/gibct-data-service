# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Version, type: :model do
  describe 'when validating' do
    subject { build :version }

    let(:bad_version) { build :version, version: 123.4 }
    let(:no_version) { build :version, version: nil }
    let(:no_user) { build :version, created_at: DateTime.current, user: nil }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'requires an integer number' do
      expect(no_version).not_to be_valid
      expect(bad_version).not_to be_valid
    end

    it 'requires a pushing authority' do
      expect(no_user).not_to be_valid
    end
  end

  describe 'when determining production and preview versions' do
    before(:each) do
      create :version, :production, version: 1, created_at: 3.days.ago
      create :version, version: 2, created_at: 2.days.ago
      create :version, :production, version: 3, created_at: 1.day.ago
      create :version, version: 4, created_at: 0.days.ago
    end

    it 'can find the latest production_version' do
      expect(Version.production_version.version).to eq(3)
    end

    it 'can find the latest preview_version' do
      expect(Version.preview_version.version).to eq(4)
    end

    it 'can find the production_version on a given date and time as string' do
      expect(Version.production_version_by_time(2.days.ago.to_s).version).to eq(1)
    end

    it 'can find the production_version on a given date and time as Time' do
      expect(Version.production_version_by_time(2.days.ago).version).to eq(1)
    end

    it 'can find the preview_version on a given date and time as string' do
      expect(Version.preview_version_by_time(1.day.ago.to_s).version).to eq(2)
    end

    it 'can find the preview_version on a given date and time as Time' do
      expect(Version.preview_version_by_time(1.day.ago).version).to eq(2)
    end
  end
end
