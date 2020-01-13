# frozen_string_literal: true

require 'rails_helper'
require 'scorecard_api/client'

describe ScorecardApi::Client do
  let(:client) { described_class.new }

  it 'gets a list of schools' do
    allow(client).to receive(:perform).with(:get, 'schools', any_args).and_return(Faraday::Env.new)

    params = {
      'fields': ScorecardApi::Service::API_MAPPINGS.keys.join(','),
      'per_page': ScorecardApi::Service::MAGIC_PAGE_NUMBER.to_s,
      'page': 0
    }

    client_response = client.schools(params)
    expect(client_response).to be_an(Faraday::Env)
  end
end
