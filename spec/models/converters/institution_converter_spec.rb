# frozen_string_literal: true
require 'rails_helper'

RSpec.describe InstitutionConverter do
  subject { described_class }

  it 'converts lower case alphas to upper' do
    expect(subject.convert('abcdefgh')).to eq('ABCDEFGH')
  end

  it 'returns nil if value is blank' do
    expect(subject.convert(nil)).to be_nil
    expect(subject.convert('   ')).to be_nil
  end
end
