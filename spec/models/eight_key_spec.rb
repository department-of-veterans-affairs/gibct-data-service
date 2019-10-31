# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe EightKey, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 1
  it_behaves_like 'an exportable model', skip_lines: 1

  describe 'when validating' do
    subject(:eight_key) { build :eight_key }

    it 'has a valid factory' do
      expect(eight_key).to be_valid
    end

    it 'computes the ope6 from ope' do
      expect(eight_key.ope6).to eql(eight_key.ope[1, 5])
    end

    it 'requires a cross or an ope to be valid' do
      expect(build(:eight_key, ope: nil)).to be_valid
      expect(build(:eight_key, cross: nil)).to be_valid
      expect(build(:eight_key, ope: nil, cross: nil)).not_to be_valid
    end
  end
end
