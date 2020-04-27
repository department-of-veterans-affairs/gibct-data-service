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

  describe 'when using scope distinct_flags' do

    it 'has distinct caution flags' do
      create_list :caution_flag, 3, :accreditation_issue

      expect(CautionFlag.distinct_flags.to_a.size).to eq(1)
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

    it 'uses institution url' do
      flag = create :caution_flag,
                    :closing_settlement_pre_map,
                    :institution_url_with_protocol,
                    version_id: version.id
      create :caution_flag_rule, :closing_settlement_rule

      described_class.map(version.id)

      expect(flag.reload['link_url']).to eq(flag.institution.insturl)
    end

    it 'adds protocol to school url' do
      flag = create :caution_flag,
                    :closing_settlement_pre_map,
                    :institution_url_without_protocol,
                    version_id: version.id
      create :caution_flag_rule, :closing_settlement_rule

      described_class.map(version.id)

      expect(flag.reload['link_url']).to eq('http://' + flag.institution.insturl)
    end

    it 'adds period to link text' do
      flag = create :caution_flag,
                    :closing_settlement_pre_map,
                    :institution_without_url,
                    version_id: version.id
      rule = create :caution_flag_rule, :closing_settlement_rule

      described_class.map(version.id)

      expect(flag.reload['link_text']).to eq(rule.link_text + '.')
    end
  end
end
