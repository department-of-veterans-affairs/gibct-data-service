# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'

RSpec.describe 'zipcode_rates', type: :request do
  before(:each) do
    create(:version, :production)
  end

  context '#show for valid zip_code' do
    it 'returns the rates for the given zip_code' do
      create(:zipcode_rate, version: Version.current_production.number)
      get '/v0/zipcode_rates/20001'
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['data']['attributes']).to eq(
        'zip_code' => '20001',
        'mha_code' => '123',
        'mha_name' => 'Washington, DC',
        'mha_rate' => 1100.0,
        'mha_rate_grandfathered' => 1000.0
      )
    end
  end

  context '#show for invalid zip_code' do
    it 'returns an error' do
      get '/v0/zipcode_rates/12345'
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['errors'].first).to eq(
        'title' => 'Record not found',
        'detail' => 'The record identified by 12345 could not be found',
        'code' => '404',
        'status' => '404'
      )
    end
  end
end
