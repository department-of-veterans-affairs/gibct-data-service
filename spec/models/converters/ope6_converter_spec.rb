# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Ope6Converter do
  subject { described_class }

  it 'right justifies with leading 0s to 5 digits in length' do
    expect(subject.convert('12345678')).to eq('23456')
  end

  it 'returns nil if value is blank' do
    expect(subject.convert(nil)).to be_nil
    expect(subject.convert('   ')).to be_nil
  end
end
