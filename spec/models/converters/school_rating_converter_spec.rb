# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SchoolRatingConverter do
  subject { described_class }

  it 'returns nil if value is blank' do
    expect(described_class.convert(nil)).to be_nil
    expect(described_class.convert('   ')).to be_nil
  end

  it 'correctly parses value as int' do
    expect(described_class.convert(3)).to eq(3)
  end

  it 'correctly converts float value to int' do
    expect(described_class.convert(3.75)).to eq(3)
  end

  it 'returns nil if value is less than 1' do
    expect(described_class.convert(0)).to be_nil
    expect(described_class.convert(-5)).to be_nil
  end

  it 'only allows 5 as max ranking value' do
    expect(described_class.convert(6)).to eq(5)
  end
end
