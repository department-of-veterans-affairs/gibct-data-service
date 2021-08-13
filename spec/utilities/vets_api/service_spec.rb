# frozen_string_literal: true

require 'rails_helper'

describe VetsApi::Service do
  let(:client_instance) { instance_double(VetsApi::Client) }

  describe 'feature_enabled?' do
    let(:body) { { data: { features: [{ name: 'feature_flag', value: true }] } } }
    let(:response) do
      response = Faraday::Env.new
      response[:body] = body
      response
    end

    it 'calls VetsApi::Client' do
      allow(VetsApi::Client).to receive(:new).and_return(client_instance)
      allow(client_instance).to receive(:feature_toggles).and_return(response)

      enabled = described_class.feature_enabled?('feature_flag')

      expect(enabled).to eq(true)
    end
  end
end
