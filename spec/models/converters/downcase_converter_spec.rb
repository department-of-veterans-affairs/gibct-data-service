# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DowncaseConverter do
  subject { described_class }

  it 'Downcases strings' do
    expect(subject.convert('a - sPAce')).to eq('a - space')
  end

  it 'converts blanks to nil' do
    expect(subject.convert(nil)).to be_nil
    expect(subject.convert('      ')).to be_nil
  end
end
