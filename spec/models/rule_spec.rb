# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rule, type: :model do
  describe 'when validating' do
    subject(:rule) { build :rule }

    it 'has a valid factory' do
      expect(rule).to be_valid
    end

    it 'requires a valid rule_name' do
      expect(build(:rule, rule_name: nil)).not_to be_valid
    end

    it 'requires a valid matcher' do
      expect(build(:rule, matcher: nil)).not_to be_valid
    end

    it 'requires a valid rule_name in RULE_NAMES' do
      expect(build(:rule, rule_name: CautionFlag.name)).to be_valid
    end

    it 'requires a valid matcher in MATCHERS' do
      expect(build(:rule, matcher: 'has')).to be_valid
    end
  end

  describe 'when applying rules' do
    let(:rule) { build :rule }
    let(:engine) { described_class.create_engine }

    before do
      engine << [1, :is, 'test']
      engine << [2, :is, 'fake']
    end

    it 'returns subjects of matching facts' do
      subjects = described_class.apply_rule(engine, rule)
      expect(subjects).to include(1)
      expect(subjects).not_to include(2)
    end
  end
end
