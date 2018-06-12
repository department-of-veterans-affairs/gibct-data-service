# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CrossConverter do
  subject { described_class }

  it 'returns nil if value is blank' do
    expect(subject.convert(nil)).to be_nil
    expect(subject.convert('   ')).to be_nil
  end

  it 'converts any letters to upcase' do
    expect(subject.convert('123Xx4')).to eq('123XX4')
  end
end
