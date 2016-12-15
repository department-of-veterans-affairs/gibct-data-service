# frozen_string_literal: true
require 'rails_helper'
require 'models/shared_examples/shared_examples_for_savable'
require 'models/shared_examples/shared_examples_for_standardizable'

RSpec.describe Weam, type: :model do
  it_behaves_like 'a savable model', Weam
  it_behaves_like 'a standardizable model', Weam

  describe 'validates' do
    subject { build :weam }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end
  end
end
