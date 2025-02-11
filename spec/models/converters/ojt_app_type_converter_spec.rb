# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Converters::OjtAppTypeConverter do
  subject { described_class }

  # Accepted characters: G, K, P, E

  it 'converts lowercase matched character into abbreviated OJT/APP type' do
    expect(described_class.convert('k')).to eq('APP')
  end

  it 'converts upcase matched character into abbreviated OJT/APP type' do
    expect(described_class.convert('K')).to eq('APP')
  end

  it 'returns nil if the value is not a matched character' do
    expect(described_class.convert('Z')).to be_nil
    expect(described_class.convert(nil)).to be_nil
  end
end
