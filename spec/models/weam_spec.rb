# frozen_string_literal: true
require 'rails_helper'
require 'models/shared_examples/shared_examples_for_savable'
require 'models/shared_examples/shared_examples_for_standardizable'

RSpec.describe Weam, type: :model do
  it_behaves_like 'a savable model', Weam
  it_behaves_like 'a standardizable model', Weam

  describe 'when validating' do
    subject { build :weam }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end
  end

  describe 'offer_degree?' do
    let(:higher_learning) do
      build :weam, institution_of_higher_learning_indicator: 'true', non_college_degree_indicator: 'false'
    end

    let(:ncd) do
      build :weam, institution_of_higher_learning_indicator: 'false', non_college_degree_indicator: 'true'
    end

    it 'is true if institution of higher learning' do
      expect(higher_learning).to be_offer_degree
      higher_learning.institution_of_higher_learning_indicator = false
      expect(higher_learning).not_to be_offer_degree
    end

    it 'is true if institution offers non-college degree' do
      expect(ncd).to be_offer_degree
      ncd.non_college_degree_indicator = false
      expect(ncd).not_to be_offer_degree
    end
  end
end
