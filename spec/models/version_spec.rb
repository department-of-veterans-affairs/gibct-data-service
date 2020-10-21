# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Version, type: :model do
  subject(:version) { build :version, :production, user: user }

  let(:user) { create :user }

  describe 'attributes' do
    it 'does not have a uuid until saved' do
      expect(version.uuid).to be_nil
      version.save
      expect(version.uuid).not_to be_nil
    end

    it 'has gibct_link based on configuration' do
      expect(version.gibct_link).to eq(ENV['GIBCT_URL'])
    end

    describe '#as_json' do
      it 'returns attributes appropriate for API responses' do
        expect(version.as_json.keys).to eq(%i[number created_at preview])
      end
    end
  end

  describe 'when validating' do
    let(:no_user) { build :version, user: nil }
    let(:good_existing_version) { build :version, :production, number: 1, user: user }
    let(:bad_existing_version) { build :version, :production, number: 1000, user: user }

    it 'has a valid factory' do
      expect(version).to be_valid
    end

    it 'requires the requesting user' do
      expect(no_user).not_to be_valid
    end

    context 'and setting a new version' do
      it 'sets the version to the max-version + 1' do
        version.save
        expect(create(:version, :production).number).to eq(version.number + 1)
      end
    end

    context 'and rolling back' do
      it 'requires an existing version when rolling back ' do
        version.save
        expect(good_existing_version).to be_valid
        expect(bad_existing_version).not_to be_valid
      end

      it 'leaves version number as-is' do
        version.save
        rollback = create :version, :production, number: version.number
        expect(rollback.number).to eq(version.number)
      end
    end
  end

  describe 'when determining production and generating preview versions' do
    before do
      create :version, :production, created_at: 3.days.ago
      create :version, created_at: 2.days.ago
      create :version, :production, created_at: 1.day.ago
      create :version, created_at: 0.days.ago
    end

    context 'latest production version' do
      let(:version) { described_class.current_production }

      it 'has correct number' do
        expect(version.number).to eq(3)
      end

      it 'has correct attributes' do
        expect(version).to be_latest_production
        expect(version).to be_production
        expect(version).not_to be_preview
        expect(version).not_to be_latest_preview
        expect(version).not_to be_publishable
      end
    end

    context 'latest preview version' do
      let(:version) { described_class.current_preview }

      it 'has correct number' do
        expect(version.number).to eq(4)
      end

      it 'has correct attributes' do
        expect(version).not_to be_latest_production
        expect(version).not_to be_production
        expect(version).to be_preview
        expect(version).to be_latest_preview
        expect(version).not_to be_publishable
      end
    end
  end

  describe 'when determining completed preview version' do
    before do
      create :version, :production, created_at: 1.day.ago
      create :version, completed_at: 0.days.ago, created_at: 0.days.ago
    end

    context 'latest preview version' do
      let(:version) { described_class.current_preview }

      it 'has correct number' do
        expect(version.number).to eq(2)
      end

      it 'has correct attributes' do
        expect(version).not_to be_latest_production
        expect(version).not_to be_production
        expect(version).to be_preview
        expect(version).to be_latest_preview
        expect(version).to be_publishable
      end
    end
  end

  describe '#archived' do
    it 'has correct number of archived versions' do
      create :version, :production
      create :version, :production
      create :version, :production

      expect(described_class.archived.to_a.size).to eq(2)
    end
  end
end
