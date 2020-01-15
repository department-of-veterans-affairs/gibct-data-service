# frozen_string_literal: true

require 'rails_helper'
require 'common/client/middleware/response/raise_error'

describe Common::Client::Middleware::Response::RaiseError do
  let(:app) { {} }
  let(:error_prefix) { 'TEST' }
  let(:options) { { error_prefix: error_prefix } }
  let(:raise_error_instance) { described_class.new(app, options) }

  describe '#initialize' do
    it 'sets error_prefix to error_prefix in options' do
      expect(raise_error_instance.error_prefix).to eq(error_prefix)
    end

    it 'sets error_prefix to VA when options is not present' do
      error = described_class.new(app)
      expect(error.error_prefix).not_to eq(error_prefix)
    end
  end

  describe '#on_complete' do
    let(:env) do
      env = Faraday::Env.new
      env[:status] = 200
      env[:body] = {}
      env
    end

    it 'returns when status is between 200..299' do
      expect(raise_error_instance.on_complete(env)).to be_nil
    end

    describe '#raise_error!' do
      it 'raises Common::Exceptions::BackendServiceException when status is between?(400,599)' do
        env[:status] = 404

        expect { raise_error_instance.on_complete(env) }
          .to raise_error(Common::Exceptions::BackendServiceException)
      end

      it 'raises BackendUnhandledException when status is not between?(400,599)' do
        env[:status] = 604

        expect { raise_error_instance.on_complete(env) }
          .to raise_error(Common::Client::Middleware::Response::BackendUnhandledException)
      end
    end
  end
end
