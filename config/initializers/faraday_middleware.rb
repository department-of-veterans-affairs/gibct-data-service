# frozen_string_literal: true

Rails.application.config.to_prepare do
  Faraday::Response.register_middleware scorecard_api_errors: Common::Client::Middleware::Response::ScorecardApiErrors
  Faraday::Response.register_middleware json_parser: Common::Client::Middleware::Response::JsonParser
  Faraday::Response.register_middleware raise_error: Common::Client::Middleware::Response::RaiseError
  Faraday::Response.register_middleware snakecase: Common::Client::Middleware::Response::Snakecase
end