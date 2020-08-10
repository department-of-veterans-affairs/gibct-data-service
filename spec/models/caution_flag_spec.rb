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

      expect(described_class.distinct_flags.to_a.size).to eq(1)
    end
  end
end
