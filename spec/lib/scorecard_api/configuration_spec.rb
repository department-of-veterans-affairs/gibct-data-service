# frozen_string_literal: true

require 'rails_helper'
require 'scorecard_api/configuration'

describe ScorecardApi::Configuration do
  describe '.open_timeout' do
    context 'when Settings.scorecard.open_timeout is not set' do
      it 'uses the default setting' do
        expect(described_class.instance.open_timeout)
          .to eq(Common::Client::Configuration::Base.instance.open_timeout)
      end
    end
  end

  describe '.read_timeout' do
    context 'when Settings.scorecard.timeout is not set' do
      it 'uses the default setting' do
        expect(described_class.instance.read_timeout)
          .to eq(Common::Client::Configuration::Base.instance.read_timeout)
      end
    end
  end

  describe '#base_path' do
    it 'returns Settings.scorecard.url' do
      expect(described_class.instance.base_path).to eq('https://api.data.gov/ed/collegescorecard/v1/')
    end
  end

  describe '#service_name' do
    it 'returns Scorecard' do
      expect(described_class.instance.service_name).to eq('Scorecard')
    end
  end

  describe '#connection' do
    it 'is an instance of Faraday::Connection' do
      expect(described_class.instance.connection).to be_a(Faraday::Connection)
    end
  end
end
