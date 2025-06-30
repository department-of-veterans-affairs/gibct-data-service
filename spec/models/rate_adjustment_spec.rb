# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RateAdjustment, type: :model do
  subject(:rate_adjustment) { create(:rate_adjustment) }

  describe '#chapterize' do
    subject(:rate_adjustment) { create(:rate_adjustment) }

    it 'converts benefit_type integer into formatted string' do
      expect(rate_adjustment.chapterize).to eq("Ch. #{rate_adjustment.benefit_type}")
    end
  end
end
