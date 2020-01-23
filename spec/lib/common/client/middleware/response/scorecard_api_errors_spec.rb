# frozen_string_literal: true

require 'rails_helper'

describe Common::Client::Middleware::Response::ScorecardApiErrors do
  let(:error_instance) { described_class.new }

  describe '#on_complete' do
    it 'returns when status is between 200..299' do
      success_env = Faraday::Env.new
      success_env[:status] = 200
      expect(error_instance.on_complete(success_env)).to be_nil
    end

    it 'returns nil when body does not contain \"error\"' do
      failed_env = Faraday::Env.new
      failed_env[:status] = 404
      failed_env[:body] = {}
      expect(error_instance.on_complete(failed_env)).to be_nil
    end

    it 'modifies env object to have code and detail properties when status is not successful' do
      error_code = 404
      error_message = 'error message'

      failed_env = Faraday::Env.new
      failed_env[:status] = error_code
      failed_env[:body] = { 'error' => { 'code' => error_code, 'message' => error_message } }

      expect(error_instance.on_complete(failed_env)).not_to be_nil
      expect(failed_env[:body]['code']).to eq(error_code)
      expect(failed_env[:body]['detail']).to eq(error_message)
    end
  end
end
