# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CautionFlag, type: :model do
  describe 'when validating' do
    subject(:caution_flag) { build :caution_flag, version_id: version.id }

    let(:version) { build :version, :preview }

    it 'has a valid factory' do
      expect(caution_flag).to be_valid
    end
  end

  describe 'when mapping' do
    let(:version) { create :version, :preview }

    it 'sets titles for all rules' do
      create :caution_flag, :accreditation_issue_pre_map, version_id: version.id
      create :caution_flag, :settlement_pre_map, version_id: version.id
      create :caution_flag_rule, :accreditation_rule
      create :caution_flag_rule, :settlement_rule

      described_class.map(version.id)

      expect(described_class.select(:title)
                 .where(version_id: version.id).pluck(:title)).to all(be)
    end
  end
end
