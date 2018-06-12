# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StateConverter do
  subject { described_class }

  it 'converts long state names to upcased abbreviations' do
    expect(subject.convert('New york')).to eq('NY')
  end

  it 'accepts states that are abbreviated' do
    expect(subject.convert('ny')).to eq('NY')
  end

  it 'returns nil if the value is not a state' do
    expect(subject.convert(nil)).to be_nil
    expect(subject.convert('          ')).to be_nil
    expect(subject.convert('Freedonia')).to be_nil
  end
end
