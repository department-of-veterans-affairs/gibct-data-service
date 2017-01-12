# frozen_string_literal: true
require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe EightKey, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 1, remove_unmapped_keys: true
  it_behaves_like 'an exportable model', skip_lines: 1, remove_unmapped_keys: true

  describe 'when validating' do
    subject { build :eight_key }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'requires cross or ope to be valid' do
      expect(build(:eight_key, ope: nil)).to be_valid
      expect(build(:eight_key, cross: nil)).to be_valid
      expect(build(:eight_key, ope: nil, cross: nil)).not_to be_valid
    end
  end
end
