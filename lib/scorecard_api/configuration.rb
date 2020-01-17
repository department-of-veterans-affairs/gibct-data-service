# frozen_string_literal: true

require 'common/client/middleware/response/scorecard_api_errors'
require 'common/client/middleware/response/json_parser'
require 'common/client/middleware/response/raise_error'
require 'common/client/middleware/response/snakecase'

module ScorecardApi
  class Configuration < Common::Client::Configuration::REST
    self.read_timeout = Settings.scorecard.read_timeout || read_timeout
    self.open_timeout = Settings.scorecard.open_timeout || open_timeout

    def base_path
      "#{Settings.scorecard.url}/"
    end

    def service_name
      'Scorecard'
    end

    def connection
      Faraday.new(base_path, headers: base_request_headers, request: request_options) do |conn|
        conn.request :json

        conn.response :snakecase
        conn.response :raise_error, error_prefix: service_name
        conn.response :scorecard_api_errors
        conn.response :json_parser

        conn.adapter Faraday.default_adapter
      end
    end
  end
end
