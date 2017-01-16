# frozen_string_literal: true
require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe Scorecard, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject { build :scorecard }

    let(:by_c150_4_pooled_supp) { create(:scorecard, :by_c150_4_pooled_supp) }
    let(:by_c150_l4_pooled_supp) { create(:scorecard, :by_c150_l4_pooled_supp) }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'will use either the c150_4_pooled_supp or the c150_l4_pooled_supp if only one is present' do
      expect(by_c150_4_pooled_supp.graduation_rate_all_students).to eq(by_c150_4_pooled_supp.c150_4_pooled_supp)
      expect(by_c150_l4_pooled_supp.graduation_rate_all_students).to eq(by_c150_l4_pooled_supp.c150_l4_pooled_supp)
    end

    it 'prefers c150_4_pooled_supp over c150_l4_pooled_supp' do
      subject.valid?
      expect(subject.graduation_rate_all_students).to eq(subject.c150_4_pooled_supp)
    end
  end
end
