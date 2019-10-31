# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe Hcm, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 2
  it_behaves_like 'an exportable model', skip_lines: 2

  describe 'when validating' do
    subject(:hcm) { build :hcm }

    it 'has a valid factory' do
      expect(hcm).to be_valid
    end

    it 'requires a valid ope' do
      expect(build(:hcm, ope: nil)).not_to be_valid
    end

    it 'requires valid hcm_type' do
      expect(build(:hcm, hcm_type: nil)).not_to be_valid
    end

    it 'requires valid hcm_reason' do
      expect(build(:hcm, hcm_reason: nil)).not_to be_valid
    end

    it 'computes the ope6 from ope' do
      expect(hcm.ope6).to eql(hcm.ope[1, 5])
    end
  end
end
