# frozen_string_literal: true
require 'rails_helper'

RSpec.describe FloatConverter do
  subject { described_class }

  it 'converts float strings to floats' do
    expect(subject.convert('01234.123')).to eq(1234.123)
  end

  it 'converts integer strings to floats' do
    expect(subject.convert('01234')).to eq(1234.0)
  end

  it 'returns nil if value is blank' do
    expect(subject.convert(nil)).to be_nil
    expect(subject.convert('   ')).to be_nil
  end
end
