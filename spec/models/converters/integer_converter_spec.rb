# frozen_string_literal: true
require 'rails_helper'

RSpec.describe IntegerConverter do
  subject { described_class }

  it 'converts integer strings to integers' do
    expect(subject.convert('01234')).to eq(1234)
  end

  it 'converts float strings to integers' do
    expect(subject.convert('01234.0')).to eq(1234)
  end

  it 'returns nil if value is blank' do
    expect(subject.convert(nil)).to be_nil
    expect(subject.convert('   ')).to be_nil
  end
end
