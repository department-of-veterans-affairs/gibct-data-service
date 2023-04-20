# frozen_string_literal: true

module Common
  module Client
    module Middleware
      module Response
        class JsonParser < Faraday::Response::Middleware
          WHITESPACE_REGEX = /\A^\s*$\z/.freeze
          UNPARSABLE_STATUS_CODES = [204, 301, 302, 304].freeze

          def on_complete(env)
            if env.response_headers['content-type']&.match?(/\bjson/)
              if !env.body.empty? && is_whitespace?(env.body)
                env.body = ''
              else
                env.body = parse(env.body) unless UNPARSABLE_STATUS_CODES.include?(env[:status])
              end
            end
          end

          def parse(body = nil)
            Oj.load(body)
          rescue Oj::Error => e
            raise Common::Client::Errors::Serialization, e
          end

          def is_whitespace?(body)
            return body =~ WHITESPACE_REGEX if body.is_a? String

            # Should be a Hash
            is_whitespace = body.values.all? do |value|
              value.is_a?(String) && value.strip.empty?
            end
          end
        end
      end
    end
  end
end
