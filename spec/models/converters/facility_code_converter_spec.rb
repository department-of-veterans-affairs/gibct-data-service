# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FacilityCodeConverter do
  subject { described_class }

  it 'converts lower case alphas to upper' do
    expect(described_class.convert('abcdefgh')).to eq('ABCDEFGH')
  end

  it 'right justifies with leading 0s to 8 characters in length' do
    expect(described_class.convert('a')).to eq('0000000A')
  end

  it 'returns nil if value is blank' do
    expect(described_class.convert(nil)).to be_nil
    expect(described_class.convert('   ')).to be_nil
  end
end
