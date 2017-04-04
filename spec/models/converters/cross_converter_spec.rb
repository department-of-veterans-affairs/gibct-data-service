# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CrossConverter do
  subject { described_class }

  it 'right justifies with leading 0s to 8 digits in length' do
    expect(subject.convert('1')).to eq('00000001')
  end

  it 'returns nil if value is blank' do
    expect(subject.convert(nil)).to be_nil
    expect(subject.convert('   ')).to be_nil
  end

  it 'converts any letters to upcase' do
    expect(subject.convert('123Xx4')).to eq('00123XX4')
  end
end
