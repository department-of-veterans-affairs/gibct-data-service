# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpcaseConverter do
  subject { described_class }

  it 'Upcases strings' do
    expect(described_class.convert('a - sPAce')).to eq('A - SPACE')
  end

  it 'converts blanks to nil' do
    expect(described_class.convert(nil)).to be_nil
    expect(described_class.convert('      ')).to be_nil
  end
end
