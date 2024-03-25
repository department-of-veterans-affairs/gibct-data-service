# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe IpedsHd, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject(:ipeds_hd) { build :ipeds_hd }

    it 'has a valid factory' do
      expect(ipeds_hd).to be_valid
    end

    it 'requires a valid cross' do
      expect(build(:ipeds_hd, cross: nil)).not_to be_valid
    end
  end

  describe '#full_address' do
    it 'returns an array' do
      expect(build(:ipeds_hd, :with_address).full_address).to be_a(Array)
      expect(build(:ipeds_hd, :with_address).full_address).to eq ['123 Main St.', 'San Francisco', 'CA', '94107']
    end
  end

  describe 'when deleting an instance' do
    before do
      create(:ipeds_hd)
      create(:crosswalk_issue, ipeds_hd: described_class.last)
    end

    it 'deletes associated crosswalk issue records' do
      expect { described_class.last.destroy }.to change(CrosswalkIssue, :count).by(-1)
    end
  end
end
