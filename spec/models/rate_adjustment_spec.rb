# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RateAdjustment, type: :model do
  subject(:rate_adjustment) { create(:rate_adjustment) }

  describe 'when validating' do
    it 'has a valid factory' do
      expect(rate_adjustment).to be_valid
    end

    it 'requires uniqueness' do
      expect(rate_adjustment.dup).not_to be_valid
    end

    it 'requires benefit type' do
      expect(build(:rate_adjustment, benefit_type: nil)).not_to be_valid
    end

    it 'requires benefit type greater than zero' do
      expect(build(:rate_adjustment, benefit_type: 0)).not_to be_valid
    end

    it 'requires rate' do
      expect(build(:rate_adjustment, rate: nil)).not_to be_valid
    end

    it 'requires rate greater than or equal to zero' do
      expect(build(:rate_adjustment, rate: -1)).not_to be_valid
    end
  end

  describe '.by_chapter_number' do
    before do
      # Reverse range to ensure order by created_at and benefit_type do not yield same result
      (1..5).to_a.reverse.each do |n|
        create(:rate_adjustment, benefit_type: n)
      end
    end
    
    it 'sorts rate adjustments numerically by benefit type' do
      rates = described_class.by_chapter_number
      expect(rates.pluck(:benefit_type)).to eq((1..5).to_a)
    end
  end

  describe '#chapterize' do
    subject(:rate_adjustment) { create(:rate_adjustment) }

    it 'converts benefit_type integer into formatted string' do
      expect(rate_adjustment.chapterize).to eq("Ch. #{rate_adjustment.benefit_type}")
    end
  end
end
