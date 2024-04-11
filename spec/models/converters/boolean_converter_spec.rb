# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Converters::BooleanConverter do
  subject { described_class }

  it 'converts strings to booleans' do
    %w[TruE T yes ye y 1 on].each do |value|
      expect(described_class.convert(value)).to be_truthy
    end
  end

  it 'converts numbers to booleans' do
    expect(described_class.convert(1)).to be_truthy
    expect(described_class.convert(2)).to be_falsey
  end

  it 'converts non-truthy strings to falsey' do
    expect(described_class.convert('some random string')).to be_falsey
  end

  it 'converts blanks to nil' do
    expect(described_class.convert(nil)).to be_nil
    expect(described_class.convert('      ')).to be_nil
  end
end
