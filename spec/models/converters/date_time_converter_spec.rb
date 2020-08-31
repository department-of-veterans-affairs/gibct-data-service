# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DateTimeConverter do
  subject { described_class }

  it 'converts strings to dates' do
    date_string = '2020-01-01T12:05:02+08:00'
    expect(described_class.convert(date_string)).to eq(DateTime.parse(date_string))
  end

  it 'converts blank value to nil' do
    expect(described_class.convert('')).to be_nil
  end

  # TODO: we should find a way to pass warnings off for data that doesn't parse
  it 'converts bad date to nil' do
    expect(described_class.convert('BADDATE')).to be_nil
  end
end
