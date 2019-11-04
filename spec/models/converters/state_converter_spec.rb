# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StateConverter do
  subject { described_class }

  it 'converts long state names to upcased abbreviations' do
    expect(described_class.convert('New york')).to eq('NY')
  end

  it 'accepts states that are abbreviated' do
    expect(described_class.convert('ny')).to eq('NY')
  end

  it 'returns nil if the value is not a state' do
    expect(described_class.convert(nil)).to be_nil
    expect(described_class.convert('          ')).to be_nil
    expect(described_class.convert('Freedonia')).to be_nil
  end
end
