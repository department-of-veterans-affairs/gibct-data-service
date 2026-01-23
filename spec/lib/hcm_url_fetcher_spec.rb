# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HcmUrlFetcher do
  describe '.fetch_latest_url' do
    let(:faraday_connection) { instance_double(Faraday::Connection) }
    let(:response) { instance_double(Faraday::Response, success?: true, body: response_body, status: 200) }
    let(:response_body) { { 'mainContent' => [nil, nil, nil, nil, nil, nil, main_content_item] }.to_json }
    let(:main_content_item) { { 'data' => [{ 'data' => [{ 'href' => href }] }] } }
    let(:href) { 'https://studentaid.gov/sites/default/files/Schools-on-HCM-January-2025.xlsx' }

    before do
      allow(Faraday).to receive(:new).and_yield(faraday_connection).and_return(faraday_connection)
      allow(faraday_connection).to receive(:headers).and_return({})
      allow(faraday_connection).to receive(:get).with(described_class::HCM_JSON_URL).and_return(response)
    end

    context 'when the request is successful with an absolute URL' do
      it 'returns the href from the JSON response' do
        expect(described_class.fetch_latest_url).to eq(href)
      end
    end

    context 'when the request is successful with a relative URL' do
      let(:href) { '/sites/default/files/Schools-on-HCM-January-2025.xlsx' }

      it 'prepends the base URL' do
        expect(described_class.fetch_latest_url).to eq("#{described_class::BASE_URL}#{href}")
      end
    end

    context 'when the HTTP request fails' do
      let(:response) { instance_double(Faraday::Response, success?: false, status: 500, reason_phrase: 'Internal Server Error') }

      it 'logs an error and returns the default URL' do
        expect(Rails.logger).to receive(:error).with(/Failed to fetch HCM URL: 500/)
        expect(described_class.fetch_latest_url).to eq(described_class::DEFAULT_URL)
      end
    end

    context 'when the href is not found in the JSON structure' do
      let(:main_content_item) { { 'data' => [] } }

      it 'logs an error and returns the default URL' do
        expect(Rails.logger).to receive(:error).with(/Failed to find HCM URL parsing/)
        expect(described_class.fetch_latest_url).to eq(described_class::DEFAULT_URL)
      end
    end

    context 'when the href is nil' do
      let(:href) { nil }

      it 'logs an error and returns the default URL' do
        expect(Rails.logger).to receive(:error).with(/Failed to find HCM URL parsing/)
        expect(described_class.fetch_latest_url).to eq(described_class::DEFAULT_URL)
      end
    end

    context 'when JSON parsing fails' do
      let(:response) { instance_double(Faraday::Response, success?: true, body: 'not valid json') }

      it 'logs an error and returns the default URL' do
        expect(Rails.logger).to receive(:error).with(/Failed to fetch HCM URL/)
        expect(described_class.fetch_latest_url).to eq(described_class::DEFAULT_URL)
      end
    end

    context 'when a network error occurs' do
      before do
        allow(faraday_connection).to receive(:get).and_raise(Faraday::ConnectionFailed.new('Connection refused'))
      end

      it 'logs an error and returns the default URL' do
        expect(Rails.logger).to receive(:error).with(/Failed to fetch HCM URL: Connection refused/)
        expect(described_class.fetch_latest_url).to eq(described_class::DEFAULT_URL)
      end
    end

    context 'when a timeout occurs' do
      before do
        allow(faraday_connection).to receive(:get).and_raise(Faraday::TimeoutError.new('Request timed out'))
      end

      it 'logs an error and returns the default URL' do
        expect(Rails.logger).to receive(:error).with(/Failed to fetch HCM URL/)
        expect(described_class.fetch_latest_url).to eq(described_class::DEFAULT_URL)
      end
    end
  end
end
