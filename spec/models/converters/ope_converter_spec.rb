# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Converters::OpeConverter do
  subject { described_class }

  it 'right justifies with leading 0s to 8 digits in length' do
    expect(described_class.convert('1')).to eq('00000001')
  end

  it 'returns nil if value is blank' do
    expect(described_class.convert(nil)).to be_nil
    expect(described_class.convert('   ')).to be_nil
  end
end
