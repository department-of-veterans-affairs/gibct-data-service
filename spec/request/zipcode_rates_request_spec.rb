# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'

RSpec.describe 'institutions', type: :request do
  let(:valid_zip_code) { '12345' }
  let(:invalid_zip_code) { '99999' }

  context '#show for valid zip_code' do
    it 'returns the zipcodes for ' do
      create(:zipcode_rate, zip_code: '12345')
      get '/v0/zipcode_rates/12345'
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['data']['attributes']).to eq(
        'zip_code' => '12345',
        'mha_code' => '123',
        'mha_name' => 'Washington, DC',
        'mha_rate' => 1111.0,
        'mha_rate_grandfathered' => 1000.0
      )
    end
  end

  context '#show for invalid zip_code' do
    it 'returns the zipcodes for ' do
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
