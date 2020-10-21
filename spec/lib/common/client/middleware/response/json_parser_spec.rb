# frozen_string_literal: true

require 'rails_helper'

describe Common::Client::Middleware::Response::JsonParser do
  let(:json_parser_instance) { described_class.new }

  describe '#on_complete' do
    it 'sets env.body to empty string when matching WHITESPACE_REGEX' do
      env = Faraday::Env.new
      env[:response_headers] = { 'content-type' => 'json' }
      env[:body] = '   '
      expect(json_parser_instance.on_complete(env)).to eq('')
    end

    it 'does not parse env.body when env.status is an UNPARSABLE_STATUS_CODES' do
      env = Faraday::Env.new
      env[:response_headers] = { 'content-type' => 'json' }
      env[:body] = {}
      env[:status] = 204
      expect(json_parser_instance.on_complete(env)).to be_nil
    end

    # rubocop:disable Style/StringLiterals
    it 'parses env.body when env.status is not an UNPARSABLE_STATUS_CODES' do
      env = Faraday::Env.new
      env[:response_headers] = { 'content-type' => 'json' }
      env[:body] = '{"metadata": {"total": 7112, "page": 71, "per_page": 100}}'
      env[:status] = 200

      json_object = { "metadata" => { "total" => 7112, "page" => 71, "per_page" => 100 } }
      expect(json_parser_instance.on_complete(env)).to eq(json_object)
    end
    # rubocop:enable Style/StringLiterals
  end
end
