# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Version, type: :model do
  describe 'attributes' do
    subject { build :version, :production }

    it 'does not have a uuid until saved' do
      expect(subject.uuid).to be_nil
      subject.save
      expect(subject.uuid).not_to be_nil
    end

    it 'has gibct_link based on configuration' do
      subject.save
      expect(subject.gibct_link).to eq(ENV['GIBCT_URL'])
    end
  end

  describe 'when validating' do
    subject { build :version, :production }

    let(:no_user) { build :version, user: nil }
    let(:good_existing_version) { build :version, :production, number: 1 }
    let(:bad_existing_version) { build :version, :production, number: 1000 }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'requires the requesting user' do
      expect(no_user).not_to be_valid
    end

    context 'and setting a new version' do
      it 'sets the version to the max-version + 1' do
        subject.save
        expect(create(:version, :production).number).to eq(subject.number + 1)
      end
    end

    context 'and rolling back' do
      it 'requires an existing version when rolling back ' do
        subject.save
        expect(good_existing_version).to be_valid
        expect(bad_existing_version).not_to be_valid
      end

      it 'leaves version number as-is' do
        subject.save
        rollback = create :version, :production, number: subject.number
        expect(rollback.number).to eq(subject.number)
      end
    end
  end

  describe 'when determining production and preview versions' do
    before(:each) do
      create :version, :production, created_at: 3.days.ago
      create :version, created_at: 2.days.ago
      create :version, :production, created_at: 1.day.ago
      create :version, created_at: 0.days.ago
    end

    context 'latest production version' do
      let(:subject) { Version.production_version }

      it 'has correct number' do
        expect(subject.number).to eq(3)
      end

      it 'has correct attributes' do
        expect(subject.latest_production?).to be_truthy
        expect(subject.production?).to be_truthy
        expect(subject.preview?).to be_falsey
        expect(subject.latest_preview?).to be_falsey
        expect(subject.publishable?).to be_falsey
      end
    end

    context 'latest preview version' do
      let(:subject) { Version.preview_version }

      it 'has correct number' do
        expect(subject.number).to eq(4)
      end

      it 'has correct attributes' do
        expect(subject.latest_production?).to be_falsey
        expect(subject.production?).to be_falsey
        expect(subject.preview?).to be_truthy
        expect(subject.latest_preview?).to be_truthy
        expect(subject.publishable?).to be_truthy
      end
    end
  end
end
