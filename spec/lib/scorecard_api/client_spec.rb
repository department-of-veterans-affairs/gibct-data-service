# frozen_string_literal: true

require 'rails_helper'

describe ScorecardApi::Client do
  let(:client) { described_class.new }

  it 'gets a list of schools' do
    expect(client).to receive(:perform)
    client.schools({})
  end
end
