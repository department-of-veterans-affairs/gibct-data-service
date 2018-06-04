# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DateConverter do
  subject { described_class }

  it 'converts strings to dates' do
    expect(subject.convert('4/17/2017')).to eq(Date.parse('April 17, 2017'))
  end

  it 'converts blank value to nil' do
    expect(subject.convert('')).to be_nil
  end

  # TODO: we should find a way to pass warnings off for data that doesn't parse
  it 'converts bad date to nil' do
    expect(subject.convert('BADDATE')).to be_nil
  end
end
