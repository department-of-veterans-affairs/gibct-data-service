# frozen_string_literal: true

require 'common/client/configuration/rest'

module Specs
  module Common
    module Client
      class DefaultConfiguration < ::Common::Client::Configuration::REST
        def connection
          @connection ||= Faraday.new(base_path) do |faraday|
            faraday.use Faraday::Response::RaiseError unless adapter_only
            faraday.adapter :httpclient
          end
        end

        def service_name
          'foo'
        end

        def adapter_only
          false
        end

        def port
          3010
        end

        def use_example_path
          true
        end

        def base_path
          use_example_path ? 'http://example.com' : "http://127.0.0.1:#{port}"
        end
      end
    end
  end
end
