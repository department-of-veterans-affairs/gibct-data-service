# frozen_string_literal: true
require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe Settlement, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject { build :settlement }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'requires a valid cross' do
      expect(build(:settlement, cross: nil)).not_to be_valid
    end

    it 'requires a valid settlement_description' do
      expect(build(:settlement, settlement_description: nil)).not_to be_valid
    end
  end
end
