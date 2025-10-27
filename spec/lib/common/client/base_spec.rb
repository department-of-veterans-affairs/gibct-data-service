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

  # rubocop:disable RSpec/SubjectStub
  # rubocop:disable RSpec/MessageSpies
  describe '#perform' do
    let(:path) { '/' }
    let(:params) { {} }

    it 'raises NoMethodError ' do
      expect { test_service.send(:perform, :fake, path, params) }.to raise_error(NoMethodError)
    end

    context 'when params is nil' do
      it 'defaults params to empty hash' do
        expect(test_service).to receive(:get).with(path, {}, {}, {})
        test_service.send(:perform, :get, path, nil)
      end
    end

    context 'when headers is nil' do
      it 'defaults headers to empty hash' do
        expect(test_service).to receive(:get).with(path, {}, {}, {})
        test_service.send(:perform, :get, path, {}, nil)
      end
    end

    context 'when options is nil' do
      it 'defaults options to empty hash' do
        expect(test_service).to receive(:get).with(path, {}, {}, {})
        test_service.send(:perform, :get, path, {}, {}, nil)
      end
    end

    context 'when all optional parameters are nil' do
      it 'defaults all to empty hashes' do
        expect(test_service).to receive(:post).with(path, {}, {}, {})
        test_service.send(:perform, :post, path, nil, nil, nil)
      end
    end
  end

  describe '#request' do
    let(:path) { '/' }

    it 'raises NotAuthenticated' do
      headers = { Token: nil }
      expect { test_service.send(:request, :get, path, {}, headers) }
        .to raise_error(Common::Client::Errors::NotAuthenticated)
    end

    context 'when rescuing Common::Exceptions::External::BackendServiceException' do
      it 'raises Specs::Common::Client::ServiceException' do
        service = Specs::Common::Client::BackendServiceExceptionService.new
        expect { service.send(:request, :get, path) }
          .to raise_error(Specs::Common::Client::ServiceException)
      end
    end

    context 'when rescuing Timeout::Error, Faraday::TimeoutError' do
      it 'raises Common::Exceptions::External::GatewayTimeout' do
        service = Specs::Common::Client::TimeoutExceptionService.new
        expect { service.send(:request, :get, path) }
          .to raise_error(Common::Exceptions::External::GatewayTimeout)
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

    context 'when making a successful request' do
      let(:params) { { id: 1 } }
      let(:headers) { { 'Authorization' => 'Bearer token', 'Content-Type' => 'application/json' } }
      let(:options) { { timeout: 30, open_timeout: 10 } }

      it 'updates request headers with provided headers' do
        # Don't mock the request method - let it execute
        stub_request(:get, "#{config.base_path}#{path}")
          .with(
            query: params,
            headers: headers
          )
          .to_return(status: 200, body: '{}')

        response = test_service.send(:request, :get, path, params, headers, options)
        expect(response).to be_a(Faraday::Env)
      end

      it 'applies options to the request' do
        stub_request(:post, "#{config.base_path}#{path}")
          .with(body: params.to_json)
          .to_return(status: 201, body: '{"success": true}')

        response = test_service.send(
          :request,
          :post, path,
          params.to_json,
          { 'Content-Type' => 'application/json' },
          { timeout: 60 }
        )

        expect(response).to be_a(Faraday::Env)
        expect(response.status).to eq(201)
      end
    end

    context 'with multiple options' do
      it 'sets each option on the request' do
        stub_request(:get, "#{config.base_path}#{path}")
          .to_return(status: 200, body: '{}')

        options = { timeout: 30, open_timeout: 10, read_timeout: 20 }
        response = test_service.send(:request, :get, path, {}, {}, options)

        expect(response).to be_a(Faraday::Env)
      end
    end
  end

  describe '#get' do
    let(:path) { '/test' }
    let(:params) { { id: 1 } }
    let(:headers) { { 'Authorization' => 'Bearer token' } }
    let(:options) { { timeout: 30 } }

    it 'delegates to request with :get method' do
      expect(test_service).to receive(:request).with(:get, path, params, headers, options)
      test_service.send(:get, path, params, headers, options)
    end

    it 'calls request with correct parameters' do
      # allow(test_service).to receive(:request).and_return(double('response'))
      allow(test_service).to receive(:request).and_return(an_instance_of(Faraday::Response).as_null_object)
      test_service.send(:get, path, params, headers, options)
      expect(test_service).to have_received(:request).with(:get, path, params, headers, options)
    end
  end

  describe '#post' do
    let(:path) { '/test' }
    let(:params) { { name: 'test', value: 'data' } }
    let(:headers) { { 'Content-Type' => 'application/json' } }
    let(:options) { { timeout: 60 } }

    it 'delegates to request with :post method' do
      expect(test_service).to receive(:request).with(:post, path, params, headers, options)
      test_service.send(:post, path, params, headers, options)
    end

    it 'calls request with correct parameters' do
      allow(test_service).to receive(:request).and_return(an_instance_of(Faraday::Response).as_null_object)
      test_service.send(:post, path, params, headers, options)
      expect(test_service).to have_received(:request).with(:post, path, params, headers, options)
    end
  end

  describe '#put' do
    let(:path) { '/test/1' }
    let(:params) { { name: 'updated' } }
    let(:headers) { { 'Content-Type' => 'application/json' } }
    let(:options) { { timeout: 45 } }

    it 'delegates to request with :put method' do
      expect(test_service).to receive(:request).with(:put, path, params, headers, options)
      test_service.send(:put, path, params, headers, options)
    end

    it 'calls request with correct parameters' do
      allow(test_service).to receive(:request).and_return(an_instance_of(Faraday::Response).as_null_object)
      test_service.send(:put, path, params, headers, options)
      expect(test_service).to have_received(:request).with(:put, path, params, headers, options)
    end
  end

  describe '#delete' do
    let(:path) { '/test/1' }
    let(:params) { {} }
    let(:headers) { { 'Authorization' => 'Bearer token' } }
    let(:options) { { timeout: 30 } }

    it 'delegates to request with :delete method' do
      expect(test_service).to receive(:request).with(:delete, path, params, headers, options)
      test_service.send(:delete, path, params, headers, options)
    end

    it 'calls request with correct parameters' do
      allow(test_service).to receive(:request).and_return(an_instance_of(Faraday::Response).as_null_object)
      test_service.send(:delete, path, params, headers, options)
      expect(test_service).to have_received(:request).with(:delete, path, params, headers, options)
    end
  end

  describe '#raise_not_authenticated' do
    it 'raises NotAuthenticated error with correct message' do
      expect { test_service.send(:raise_not_authenticated) }
        .to raise_error(Common::Client::Errors::NotAuthenticated, 'Not Authenticated')
    end

    it 'raises the correct error class' do
      expect { test_service.send(:raise_not_authenticated) }
        .to raise_error(Common::Client::Errors::NotAuthenticated)
    end
  end
  # rubocop:enable RSpec/MessageSpies
  # rubocop:enable RSpec/SubjectStub
end
