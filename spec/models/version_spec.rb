# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Version, type: :model do
  describe 'buildable?' do
    subject { described_class }

    let(:preview_date) { Faker::Time.between(2.days.ago, Time.zone.today, :all) }
    let(:after_preview_date) { Faker::Date.between(preview_date + 1, preview_date + 2.days.to_i) }
    let(:before_preview_date) { Faker::Date.between(preview_date - 2.days.to_i, preview_date - 1) }
    let(:upload_dates_after) { [after_preview_date] * 21 }
    let(:upload_dates_before) { [before_preview_date] * 21 }

    it 'returns false if upload dates is less than institution table count' do
      allow(Upload).to receive_message_chain(:last_uploads, :to_a, :map)
        .and_return(upload_dates_after[0..19])
      expect(subject.buildable_state).to eq(:not_enough_uploads)
      expect(subject.buildable?).to be_falsey
    end

    it 'returns false if upload dates is more than institution table count' do
      allow(Upload).to receive_message_chain(:last_uploads, :to_a, :map)
        .and_return(upload_dates_after + [upload_dates_after.first])
      expect(subject.buildable_state).to eq(:too_many_uploads)
      expect(subject.buildable?).to be_falsey
    end

    context 'with no preview version' do
      it 'returns true if upload dates are before' do
        allow(Upload).to receive_message_chain(:last_uploads, :to_a, :map)
          .and_return(upload_dates_before)
        expect(subject.buildable_state).to eq(:can_create_first_preview)
        expect(subject.buildable?).to be_truthy
      end

      it 'returns true if upload dates are after' do
        allow(Upload).to receive_message_chain(:last_uploads, :to_a, :map)
          .and_return(upload_dates_after)
        expect(subject.buildable_state).to eq(:can_create_first_preview)
        expect(subject.buildable?).to be_truthy
      end
    end

    context 'with preview version' do
      before(:each) { create :version, created_at: preview_date }

      it 'returns false if upload dates are before' do
        allow(Upload).to receive_message_chain(:last_uploads, :to_a, :map)
          .and_return(upload_dates_before)
        expect(subject.buildable_state).to eq(:no_new_uploads)
        expect(subject.buildable?).to be_falsey
      end

      it 'returns false if upload dates are before' do
        allow(Upload).to receive_message_chain(:last_uploads, :to_a, :map)
          .and_return(upload_dates_after)
        expect(subject.buildable_state).to eq(:can_create_new_preview)
        expect(subject.buildable?).to be_truthy
      end
    end
  end

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
      let(:subject) { Version.current_production }

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
      let(:subject) { Version.current_preview }

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
