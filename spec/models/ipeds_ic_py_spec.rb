# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe IpedsIcPy, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject { build :ipeds_ic_py }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'requires cross' do
      expect(build(:ipeds_ic_py, cross: nil)).not_to be_valid
    end

    it 'requires numeric chg1py3' do
      expect(build(:ipeds_ic_py, chg1py3: 'abc')).not_to be_valid
    end

    it 'requires numeric books' do
      expect(build(:ipeds_ic_py, books: 'abc')).not_to be_valid
    end

    it 'sets tuition_in_state and tuition_out_of_state' do
      expect(subject.tuition_in_state).to eq(subject.chg1py3)
      expect(subject.tuition_out_of_state).to eq(subject.chg1py3)
    end
  end
end
