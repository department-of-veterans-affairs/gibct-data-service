# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe ScorecardDegreeProgram, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject(:scorecard_degree_program) { build :scorecard_degree_program }

    it 'has a valid factory' do
      expect(scorecard_degree_program).to be_valid
    end
  end

  describe 'populate' do
    subject(:scorecard_degree_program) { build :scorecard_degree_program }

    it 'causes populate to be called for a CSV' do
      allow(ScorecardApi::Service).to receive(:populate).and_return([scorecard_degree_program])
      allow(described_class).to receive(:load)
      message = described_class.populate

      expect(message).to be_truthy
      expect(ScorecardApi::Service).to have_received(:populate)
      expxect(described_class).to have_received(:load)
    end
  end
end
