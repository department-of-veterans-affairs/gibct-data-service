# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe Outcome, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject(:outcome) { build :outcome }

    it 'has a valid factory' do
      expect(outcome).to be_valid
    end

    it 'requires a valid facility_code' do
      expect(build(:outcome, facility_code: nil)).not_to be_valid
    end

    it 'allows retention_rate_veteran_ba to have a non-numeric value of blank' do
      expect(build(:outcome, retention_rate_veteran_ba: '')).to be_valid
    end

    it 'allows retention_rate_veteran_ba to have a non-numeric value of nil' do
      expect(build(:outcome, retention_rate_veteran_ba: nil)).to be_valid
    end

    it 'requires numeric retention_rate_veteran_ba' do
      expect(build(:outcome, retention_rate_veteran_ba: 'abc')).not_to be_valid
    end

    it 'allows retention_rate_veteran_otb to have a non-numeric value of blank' do
      expect(build(:outcome, retention_rate_veteran_otb: '')).to be_valid
    end

    it 'allows retention_rate_veteran_otb to have a non-numeric value of nil' do
      expect(build(:outcome, retention_rate_veteran_otb: nil)).to be_valid
    end

    it 'requires numeric retention_rate_veteran_otb' do
      expect(build(:outcome, retention_rate_veteran_otb: 'abc')).not_to be_valid
    end

    it 'allows persistance_rate_veteran_ba to have a non-numeric value of blank' do
      expect(build(:outcome, persistance_rate_veteran_ba: '')).to be_valid
    end

    it 'allows persistance_rate_veteran_ba to have a non-numeric value of nil' do
      expect(build(:outcome, persistance_rate_veteran_ba: nil)).to be_valid
    end

    it 'requires numeric persistance_rate_veteran_ba' do
      expect(build(:outcome, persistance_rate_veteran_ba: 'abc')).not_to be_valid
    end

    it 'allows persistance_rate_veteran_otb to have a non-numeric value of blank' do
      expect(build(:outcome, persistance_rate_veteran_otb: '')).to be_valid
    end

    it 'allows persistance_rate_veteran_otb to have a non-numeric value of nil' do
      expect(build(:outcome, persistance_rate_veteran_otb: nil)).to be_valid
    end

    it 'requires numeric persistance_rate_veteran_otb' do
      expect(build(:outcome, persistance_rate_veteran_otb: 'abc')).not_to be_valid
    end

    it 'allows graduation_rate_veteran to have a non-numeric value of blank' do
      expect(build(:outcome, graduation_rate_veteran: '')).to be_valid
    end

    it 'allows graduation_rate_veteran to have a non-numeric value of nil' do
      expect(build(:outcome, graduation_rate_veteran: nil)).to be_valid
    end

    it 'requires numeric graduation_rate_veteran' do
      expect(build(:outcome, graduation_rate_veteran: 'abc')).not_to be_valid
    end

    it 'allows transfer_out_rate_veteran to have a non-numeric value of blank' do
      expect(build(:outcome, transfer_out_rate_veteran: '')).to be_valid
    end

    it 'allows transfer_out_rate_veteran to have a non-numeric value of nil' do
      expect(build(:outcome, transfer_out_rate_veteran: nil)).to be_valid
    end

    it 'requires numeric transfer_out_rate_veteran' do
      expect(build(:outcome, transfer_out_rate_veteran: 'abc')).not_to be_valid
    end
  end
end
