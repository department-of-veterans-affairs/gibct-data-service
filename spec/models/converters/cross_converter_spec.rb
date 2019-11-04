# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CrossConverter do
  subject { described_class }

  it 'returns nil if value is blank' do
    expect(described_class.convert(nil)).to be_nil
    expect(described_class.convert('   ')).to be_nil
  end

  it 'converts any letters to upcase' do
    expect(described_class.convert('123Xx4')).to eq('123XX4')
  end
end
