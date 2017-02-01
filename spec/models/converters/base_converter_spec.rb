# frozen_string_literal: true
require 'rails_helper'

RSpec.describe BaseConverter do
  subject { described_class }

  it 'strips strings' do
    expect(subject.convert('     t    ')).to eq('t')
  end

  it 'converts forbidden words to nil' do
    %w(None NuLl PrIvAcYsUpPrEsSeD).each do |word|
      expect(subject.convert(word)).to be_nil
    end
  end

  it 'converts nil to nil' do
    expect(subject.convert(nil)).to be_nil
  end

  it 'converts blanks to an empty string' do
    expect(subject.convert('      ')).to be_blank
  end
end
