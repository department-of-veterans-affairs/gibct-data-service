# frozen_string_literal: true

module VetsApi
  class Configuration < Common::Client::Configuration::REST
    self.read_timeout = Settings.vets_api&.read_timeout || read_timeout
    self.open_timeout = Settings.vets_api&.open_timeout || open_timeout

    def base_path
      "#{Figaro.env.link_host}/v0"
    end

    def service_name
      'Vets API'
    end

    def connection
      Faraday.new(base_path, headers: base_request_headers, request: request_options) do |conn|
        conn.request :json

        conn.response :snakecase
        conn.response :raise_error, error_prefix: service_name
        conn.response :json_parser

        conn.adapter Faraday.default_adapter
      end
    end
  end
end
