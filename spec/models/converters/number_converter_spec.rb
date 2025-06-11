# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Converters::NumberConverter do
  subject { described_class }

  it 'strips $, +, and commas from number strings' do
    expect(described_class.convert('    +$123,456.78    ')).to eq('123456.78')
  end

  it 'returns nil if value is blank' do
    expect(described_class.convert(nil)).to be_nil
    expect(described_class.convert('   ')).to be_nil
  end

  describe '.deconvert' do
    it 'returns number attribute if value is Version record' do
      value = build(:version)
      expect(described_class.deconvert(value)).to eq(value.number)
    end

    it 'returns value without deconverting if value is not Version record' do
      expect(described_class.deconvert(1)).to eq(1)
    end
  end
end
