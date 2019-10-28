# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DisplayConverter do
  subject { described_class }

  it 'capitalizes letters separated by spaces' do
    expect(described_class.convert('a sPAce')).to eq('A Space')
  end

  it 'capitalizes between dashes' do
    expect(described_class.convert('a sPaCe-space')).to eq('A Space-Space')
  end

  it 'preserves interstial spaces while capitalizing' do
    expect(described_class.convert('a   space')).to eq('A   Space')
  end

  it 'preserves interstial dashes' do
    expect(described_class.convert('a - space')).to eq('A - Space')
  end

  it 'converts blanks to nil' do
    expect(described_class.convert(nil)).to be_nil
    expect(described_class.convert('      ')).to be_nil
  end
end
