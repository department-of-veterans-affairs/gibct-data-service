# frozen_string_literal: true

require 'rails_helper'
require 'common/client/base'
require 'support/client_helper'

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
    let(:params) { {} }

    it 'raises NotAuthenticated' do
      headers = { Token: nil }
      expect { test_service.send(:request, :get, path, params, headers) }
        .to raise_error(Common::Client::Errors::NotAuthenticated)
    end

    describe '#get' do
      it 'returns status 200' do
        response = test_service.send(:perform, :get, path, params)
        expect(response.status).to eq(200)
      end

      it 'raises error' do
        response = test_service.send(:perform, :get, path, params)
        expect(response.status).to eq(200)
      end
    end

    # context 'post' do
    #  it 'should return status 200' do
    #    response = test_service.send(:perform, :post, path, params)
    #    expect(response.status).to eq(200)
    #  end
    # end
    #
    # context 'put' do
    #  it 'should return status 200' do
    #    response = test_service.send(:perform, :put, path, params)
    #    expect(response.status).to eq(200)
    #  end
    # end
    #
    # context 'delete' do
    #  it 'should return status 200' do
    #    response = test_service.send(:perform, :delete, path, params)
    #    expect(response.status).to eq(200)
    #  end
    # end
  end
end
