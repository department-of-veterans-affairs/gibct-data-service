# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe Mou, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 1
  it_behaves_like 'an exportable model', skip_lines: 1

  describe 'when validating' do
    subject { build :mou }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'requires a valid ope' do
      expect(build(:mou, ope: nil)).not_to be_valid
    end

    it 'computes the ope6 from ope[1, 5]' do
      subject.valid?
      expect(subject.ope6).to eql(subject.ope[1, 5])
    end

    it 'sets dodmou to false if status is set' do
      ['PRoBATIon - Dod', 'title IV NON-comPliant'].each do |status|
        mou = create :mou, status: status
        expect(mou.dodmou).to be_falsy
      end
    end

    it "sets dod_status if status contains 'dod'" do
      expect(create(:mou).dod_status).to be_truthy
      expect(create(:mou, :by_title_iv).dod_status).to be_falsy
    end
  end
end
