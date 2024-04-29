# frozen_string_literal: true

module Common
  module Client
    module Middleware
      module Response
        class JsonParser < Faraday::Response::Middleware
          WHITESPACE_REGEX = /\A^\s*$\z/
          UNPARSABLE_STATUS_CODES = [204, 301, 302, 304].freeze

          def on_complete(env)
            if env.response_headers['content-type']&.match?(/\bjson/)
              if env.response_body.nil? || (!env.response_body.empty? && body_is_whitespace?(env.response_body))
                env.response_body = ''
              else
                env.response_body = parse(env.response_body) unless UNPARSABLE_STATUS_CODES.include?(env[:status])
              end
            end
          end

          def parse(body = nil)
            Oj.load(body)
          rescue Oj::Error => e
            raise Common::Client::Errors::Serialization, e
          end

          def body_is_whitespace?(body)
            return body =~ WHITESPACE_REGEX if body.is_a? String

            # Should be a Hash
            body_is_whitespace = true
            body.values.all? do |value|
              body_is_whitespace = false unless value.is_a?(String) && value.strip.empty?
              break unless body_is_whitespace
            end
            body_is_whitespace
          end
        end
      end
    end
  end
end
