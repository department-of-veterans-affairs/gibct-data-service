# frozen_string_literal: true

require 'rails_helper'
require 'scorecard_api/configuration'

describe VetsApi::Configuration do
  describe '.open_timeout' do
    context 'when Settings.vets_api.open_timeout is not set' do
      it 'uses the default setting' do
        expect(described_class.instance.open_timeout)
          .to eq(Common::Client::Configuration::Base.instance.open_timeout)
      end
    end
  end

  describe '.read_timeout' do
    context 'when Settings.vets_api.timeout is not set' do
      it 'uses the default setting' do
        expect(described_class.instance.read_timeout)
          .to eq(Common::Client::Configuration::Base.instance.read_timeout)
      end
    end
  end

  describe '#base_path' do
    it 'returns LINK_HOST' do
      expect(described_class.instance.base_path).to eq('http://localhost:3000/v0')
    end
  end

  describe '#service_name' do
    it 'returns Vets API' do
      expect(described_class.instance.service_name).to eq('Vets API')
    end
  end

  describe '#connection' do
    it 'is an instance of Faraday::Connection' do
      expect(described_class.instance.connection).to be_a(Faraday::Connection)
    end
  end
end
