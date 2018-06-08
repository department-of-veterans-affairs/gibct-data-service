# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DisplayConverter do
  subject { described_class }

  it 'capitalizes letters separated by spaces' do
    expect(subject.convert('a sPAce')).to eq('A Space')
  end

  it 'capitalizes between dashes' do
    expect(subject.convert('a sPaCe-space')).to eq('A Space-Space')
  end

  it 'preserves interstial spaces while capitalizing' do
    expect(subject.convert('a   space')).to eq('A   Space')
  end

  it 'preserves interstial dashes' do
    expect(subject.convert('a - space')).to eq('A - Space')
  end

  it 'converts blanks to nil' do
    expect(subject.convert(nil)).to be_nil
    expect(subject.convert('      ')).to be_nil
  end
end
