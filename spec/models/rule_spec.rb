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
end
