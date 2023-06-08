# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DateTimeConverter do
  subject { described_class }

  it 'converts strings to date' do
    expect(described_class.convert('4/17/2017')).to eq(Date.parse('April 17, 2017'))
  end

  it 'converts datetimes to dates' do
    expect(described_class.convert(DateTime.now)).to eq(DateTime.now.to_date)
  end

  it 'returns date if date' do
    expect(described_class.convert(Date.today)).to eq(Date.today)
  end

  it 'converts blank value to nil' do
    expect(described_class.convert('')).to be_nil
  end

  # TODO: we should find a way to pass warnings off for data that doesn't parse
  it 'converts bad date to nil' do
    expect(described_class.convert('BADDATE')).to be_nil
  end
end
