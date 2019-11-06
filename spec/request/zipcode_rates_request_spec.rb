# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'

RSpec.describe 'zipcode_rates', type: :request do
  before do
    create(:version, :production)
  end

  describe '#show for valid zip_code' do
    def check_response(response)
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['data']['attributes']).to eq(
        'zip_code' => '20001',
        'mha_code' => '123',
        'mha_name' => 'Washington, DC',
        'mha_rate' => 1100.0,
        'mha_rate_grandfathered' => 1000.0
      )
    end
    it 'returns the rates for the given zip_code' do
      create(:zipcode_rate, version: Version.current_production.number)
      get '/v0/zipcode_rates/20001'
      check_response(response)
    end
  end

  describe '#show for invalid zip_code' do
    def check_errors(response)
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['errors'].first).to eq(
        'title' => 'Record not found',
        'detail' => 'The record identified by 12345 could not be found',
        'code' => '404',
        'status' => '404'
      )
    end

    it 'returns an error' do
      get '/v0/zipcode_rates/12345'
      check_errors(response)
    end
  end
end
