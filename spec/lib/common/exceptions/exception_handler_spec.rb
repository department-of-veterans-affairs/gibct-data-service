# frozen_string_literal: true

require 'rails_helper'
require 'common/exceptions/exception_handler'

RSpec.describe Common::Exceptions::ExceptionHandler do
  let(:user) { build(:user, :loa3) }
  let(:message) { 'the server responded with status 503' }
  let(:error_body) { { 'status' => 'some service unavailable status' } }
  let(:service) { 'Scorecard' }

  describe '.initialize' do
    context 'when initialized without a nil error' do
      it 'raises an exception' do
        expect { described_class.new(nil, service) }.to raise_error(Common::Exceptions::ParameterMissing)
      end
    end
  end

  describe '#serialize_error' do
    context 'with a Common::Client::Errors::ClientError' do
      let(:error) { Common::Client::Errors::ClientError.new(message, 503, error_body) }
      let(:results) { described_class.new(error, service).serialize_error }

      it 'returns a serialized version of the error' do
        expect(results).to include message, error_body.to_s
      end
    end

    context 'with a Common::Exceptions::GatewayTimeout' do
      let(:error) { Common::Exceptions::GatewayTimeout.new }
      let(:results) { described_class.new(error, service).serialize_error }

      it 'returns a serialized version of the error' do
        expect(results).to include 'Gateway timeout'
      end
    end

    def server_error_exception
      Common::Exceptions::BackendServiceException.new(
        'SCORECARD_503',
        { source: 'ScorecardApi::Client' },
        503,
        'some error body'
      )
    end

    context 'with a Common::Exceptions::BackendServiceException' do
      let(:error) { server_error_exception }
      let(:results) { described_class.new(error, service).serialize_error }

      it 'returns a serialized version of the error' do
        expect(results).to include 'Service unavailable'
      end
    end

    context 'with a StandardError' do
      let(:error) { StandardError.new(message) }
      let(:results) { described_class.new(error, service).serialize_error }

      it 'returns a serialized version of the error' do
        expect(results).to include message
      end
    end
  end
end
