# frozen_string_literal: true

require 'rails_helper'
require 'common/client/middleware/response/snakecase'

describe Common::Client::Middleware::Response::Snakecase do
  let(:app) { {} }
  let(:error_prefix) { 'TEST' }
  let(:snakecase_instance) { described_class.new(app) }

  describe '#on_complete' do
    it 'returns nil when body is not an Array or Hash' do
      string_env = Faraday::Env.new
      string_env[:body] = 'body'
      expect(snakecase_instance.on_complete(string_env)).to be_nil
    end

    it 'returns parsed body when body is an Array or Hash' do
      array_env = Faraday::Env.new
      array_env[:body] = [{ 'CamelCase' => 't' }]

      expect(snakecase_instance.on_complete(array_env)).not_to be_nil
    end
  end

  describe '#parse' do
    it 'returns parsed Array when body is an Array' do
      array_env = Faraday::Env.new
      array_env[:body] = [{ 'CamelCase' => 't' }]
      parsed_array = [{ camel_case: 't' }]

      expect(snakecase_instance.on_complete(array_env)).to eq(parsed_array)
    end

    it 'returns parsed Hash when body is an Hash' do
      hash_env = Faraday::Env.new
      hash_env[:body] = { 'CamelCase' => 't' }
      parsed_hash = { camel_case: 't' }

      expect(snakecase_instance.on_complete(hash_env)).to eq(parsed_hash)
    end
  end

  describe '#transform' do
    it 'does not return symbols when @symbolize is false' do
      non_symbol_snakecase = described_class.new(app, symbolize: false)
      hash = { 'CamelCase' => 't' }
      transformed_hash = { 'camel_case' => 't' }
      expect(non_symbol_snakecase.send(:transform, hash)).to eq(transformed_hash)
    end

    it 'returns symbols when @symbolize is true' do
      hash = { 'CamelCase' => 't' }
      transformed_hash = { camel_case: 't' }
      expect(snakecase_instance.send(:transform, hash)).to eq(transformed_hash)
    end
  end
end
