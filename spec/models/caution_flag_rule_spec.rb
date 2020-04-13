# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CautionFlagRule, type: :model do
  describe 'when validating' do
    subject(:caution_flag_rule) { build :caution_flag_rule, :accreditation_rule }

    it 'has a valid factory' do
      expect(caution_flag_rule).to be_valid
    end

    it 'requires a rule' do
      expect(build(:caution_flag_rule, rule: nil)).not_to be_valid
    end
  end
end
