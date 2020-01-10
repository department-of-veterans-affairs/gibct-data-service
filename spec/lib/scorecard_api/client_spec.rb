# frozen_string_literal: true

require 'rails_helper'
require 'scorecard_api/client'
require_relative '../../../app/modules/scorecard_service'

describe 'scorecard_api client' do
  let(:client) { ScorecardApi::Client.new }

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
