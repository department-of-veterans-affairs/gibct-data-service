# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe Crosswalk, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject(:crosswalk) { build :crosswalk }

    it 'has a valid factory' do
      expect(crosswalk).to be_valid
    end

    it 'requires a valid facility_code' do
      expect(build(:crosswalk, facility_code: nil)).not_to be_valid
    end

    it 'computes the ope6 from ope' do
      expect(crosswalk.ope6).to eql(crosswalk.ope[1, 5])
    end
  end

  describe 'associations' do
    it 'deletes crosswalk issues when deleted' do
      crosswalk = create :crosswalk, :with_crosswalk_issue
      expect do
        crosswalk.destroy
      end.to change(CrosswalkIssue, :count).by(-1)
    end
  end
end
