# frozen_string_literal: true
require 'rails_helper'

RSpec.describe OpeConverter do
  subject { described_class }

  it 'converts a string composed of a word NONE to nil' do
    expect(subject.convert('NONE')).to be_nil
  end

  it 'allows double quotation marks for OPE column strings' do
    str = %("this string has double quotes")
    expect(subject.convert(str)).to eq('"this string has double quotes"')
  end

  it 'right justifies with leading 0s to 8 digits in length' do
    expect(subject.convert('1')).to eq('00000001')
  end

  it 'returns nil if value is blank' do
    expect(subject.convert(nil)).to be_nil
    expect(subject.convert('   ')).to be_nil
  end
end
