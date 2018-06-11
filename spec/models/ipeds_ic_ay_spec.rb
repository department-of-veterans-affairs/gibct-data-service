# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe IpedsIcAy, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject { build :ipeds_ic_ay }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'requires cross' do
      expect(build(:ipeds_ic_ay, cross: nil)).not_to be_valid
    end

    it 'requires numeric tuition_in_state' do
      expect(build(:ipeds_ic_ay, tuition_in_state: 'abc')).not_to be_valid
    end

    it 'requires numeric tuition_out_of_state' do
      expect(build(:ipeds_ic_ay, tuition_out_of_state: 'abc')).not_to be_valid
    end

    it 'requires numeric books' do
      expect(build(:ipeds_ic_ay, books: 'abc')).not_to be_valid
    end
  end
end
