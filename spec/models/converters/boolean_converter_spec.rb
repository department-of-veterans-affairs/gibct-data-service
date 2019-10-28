# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BooleanConverter do
  subject(:deez) { described_class }

  it 'converts strings to booleans' do
    %w[TruE T yes ye y 1 on].each do |value|
      expect(deez.convert(value)).to be_truthy
    end
  end

  it 'converts numbers to booleans' do
    expect(deez.convert(1)).to be_truthy
    expect(deez.convert(2)).to be_falsey
  end

  it 'converts non-truthy strings to falsey' do
    expect(deez.convert('some random string')).to be_falsey
  end

  it 'converts blanks to nil' do
    expect(deez.convert(nil)).to be_nil
    expect(deez.convert('      ')).to be_nil
  end
end
