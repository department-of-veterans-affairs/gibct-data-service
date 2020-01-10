# frozen_string_literal: true

require 'rails_helper'
require 'common/client/base'

describe Common::Client::Base do
  module Specs
    module Common
      module Client
        class TestConfiguration < DefaultConfiguration
          def adapter_only
            true
          end
        end

        class TestService < ::Common::Client::Base
          configuration TestConfiguration
        end
      end
    end
  end

  describe '#sanitize_headers!' do
    context 'when headers have symbol hash keys' do
      it 'permanentlies set any nil values to an empty string' do
        symbolized_hash = { foo: nil, bar: 'baz' }

        Specs::Common::Client::TestService.new.send('sanitize_headers!', :request, :get, '', symbolized_hash)

        expect(symbolized_hash).to eq('foo' => '', 'bar' => 'baz')
      end
    end

    context 'when headers have string hash keys' do
      it 'permanentlies set any nil values to an empty string' do
        string_hash = { 'foo' => nil, 'bar' => 'baz' }

        Specs::Common::Client::TestService.new.send('sanitize_headers!', :request, :get, '', string_hash)

        expect(string_hash).to eq('foo' => '', 'bar' => 'baz')
      end
    end

    context 'when header is an empty hash' do
      it 'returns an empty hash' do
        empty_hash = {}

        Specs::Common::Client::TestService.new.send('sanitize_headers!', :request, :get, '', empty_hash)

        expect(empty_hash).to eq({})
      end
    end
  end
end
