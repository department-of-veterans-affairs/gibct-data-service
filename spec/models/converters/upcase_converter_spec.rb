# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UpcaseConverter do
  subject { described_class }

  it 'Upcases strings' do
    expect(subject.convert('a - sPAce')).to eq('A - SPACE')
  end

  it 'converts blanks to nil' do
    expect(subject.convert(nil)).to be_nil
    expect(subject.convert('      ')).to be_nil
  end
end
