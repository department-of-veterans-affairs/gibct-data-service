# frozen_string_literal: true

require 'rails_helper'
require 'common/client/base'
require 'support/client_helper'
require 'support/configuration_helper'

describe Common::Client::Base do
  subject(:test_service) { Specs::Common::Client::TestService.new }

  let(:config) { test_service.send(:config) }

  describe '#sanitize_headers!' do
    context 'when headers have symbol hash keys' do
      it 'permanentlies set any nil values to an empty string' do
        symbolized_hash = { foo: nil, bar: 'baz' }

        test_service.send('sanitize_headers!', :request, :get, '', symbolized_hash)

        expect(symbolized_hash).to eq('foo' => '', 'bar' => 'baz')
      end
    end

    context 'when headers have string hash keys' do
      it 'permanentlies set any nil values to an empty string' do
        string_hash = { 'foo' => nil, 'bar' => 'baz' }

        test_service.send('sanitize_headers!', :request, :get, '', string_hash)

        expect(string_hash).to eq('foo' => '', 'bar' => 'baz')
      end
    end

    context 'when header is an empty hash' do
      it 'returns an empty hash' do
        empty_hash = {}

        test_service.send('sanitize_headers!', :request, :get, '', empty_hash)

        expect(empty_hash).to eq({})
      end
    end
  end

  describe '#config' do
    it 'returns configuration ' do
      expect(config).to be_a(Specs::Common::Client::TestConfiguration)
      expect(config.adapter_only).to be_truthy
    end
  end

  describe '#connection' do
    it 'returns connection ' do
      connection = test_service.send(:connection)
      expect(connection).to eq(config.connection)
    end
  end

  describe '#perform' do
    let(:path) { '/' }
    let(:params) { {} }

    it 'raises NoMethodError ' do
      expect { test_service.send(:perform, :fake, path, params) }.to raise_error(NoMethodError)
    end
  end

  describe '#request' do
    let(:path) { '/' }

    it 'raises NotAuthenticated' do
      headers = { Token: nil }
      expect { test_service.send(:request, :get, path, {}, headers) }
        .to raise_error(Common::Client::Errors::NotAuthenticated)
    end

    context 'when rescuing Common::Exceptions::BackendServiceException' do
      it 'raises Specs::Common::Client::ServiceException' do
        service = Specs::Common::Client::BackendServiceExceptionService.new
        expect { service.send(:request, :get, path) }
          .to raise_error(Specs::Common::Client::ServiceException)
      end
    end

    context 'when rescuing Timeout::Error, Faraday::TimeoutError' do
      it 'raises Common::Exceptions::GatewayTimeout' do
        service = Specs::Common::Client::TimeoutExceptionService.new
        expect { service.send(:request, :get, path) }
          .to raise_error(Common::Exceptions::GatewayTimeout)
      end
    end

    context 'when rescuing Faraday::ClientError' do
      it 'raises Common::Client::Errors::ParsingError' do
        service = Specs::Common::Client::ParsingErrorExceptionService.new
        expect { service.send(:request, :get, path) }
          .to raise_error(Common::Client::Errors::ParsingError)
      end

      it 'raises Common::Client::Errors::ClientError' do
        service = Specs::Common::Client::ClientErrorExceptionService.new
        expect { service.send(:request, :get, path) }
          .to raise_error(Common::Client::Errors::ClientError)
      end
    end
  end

  describe '#get' do
    it 'returns status 200' do
      response = test_service.send(:perform, :get, '/', {})
      expect(response.status).to eq(200)
    end
  end
end
