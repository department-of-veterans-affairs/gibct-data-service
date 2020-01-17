# frozen_string_literal: true

module Common
  module Client
    module Middleware
      module Response
        class ScorecardApiErrors < Faraday::Response::Middleware
          def on_complete(env)
            return if env.success?

            mapped_error = env[:body]['error']
            return if mapped_error.nil?

            env[:body]['code'] = mapped_error['code']
            env[:body]['detail'] = mapped_error['message']
          end
        end
      end
    end
  end
end

Faraday::Response.register_middleware scorecard_api_errors: Common::Client::Middleware::Response::ScorecardApiErrors
