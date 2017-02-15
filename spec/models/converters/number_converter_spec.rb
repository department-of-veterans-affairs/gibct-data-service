# frozen_string_literal: true
require 'rails_helper'

RSpec.describe NumberConverter do
  subject { described_class }

  it 'strips $, +, and commas from number strings' do
    expect(subject.convert('    +$123,456.78    ')).to eq('123456.78')
  end

  it 'returns nil if value is blank' do
    expect(subject.convert(nil)).to be_nil
    expect(subject.convert('   ')).to be_nil
  end
end
